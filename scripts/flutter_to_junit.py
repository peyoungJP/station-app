#!/usr/bin/env python3
"""
Flutter テスト結果 JSON → JUnit XML 変換スクリプト

Flutter の --reporter json 出力は「1行1JSONオブジェクト」のストリーム形式。
Allure は JUnit XML を標準でサポートするため、このスクリプトで変換する。

使い方:
    python3 scripts/flutter_to_junit.py <input.json> <output.xml>

    入力ファイルが存在しない場合や空の場合は、空の JUnit XML を生成して
    パイプラインが止まらないようにする。
"""

import sys
import json
import xml.etree.ElementTree as ET
from xml.dom import minidom
from pathlib import Path
from datetime import datetime


def parse_flutter_json(input_path: Path) -> dict:
    """
    Flutter test JSON ストリームを解析して、テスト結果を辞書で返す。

    Flutter の test protocol では以下のイベントタイプが主要:
    - testStart : テスト開始（name, id）
    - testDone  : テスト完了（testID, result: "success" | "failure" | "error"）
    - error     : エラー詳細（testID, error, stackTrace）
    """
    tests = {}       # testID -> {name, result, error, stackTrace, duration_ms}
    errors = {}      # testID -> {error, stackTrace}
    start_times = {} # testID -> 開始時刻(ms)

    if not input_path.exists():
        return {}

    with input_path.open(encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                continue

            event_type = event.get("type")

            if event_type == "testStart":
                test = event.get("test", {})
                test_id = test.get("id")
                if test_id is not None:
                    tests[test_id] = {
                        "name": test.get("name", f"test_{test_id}"),
                        "result": None,
                        "error": None,
                        "stackTrace": None,
                        "duration_ms": 0,
                    }
                    start_times[test_id] = event.get("time", 0)

            elif event_type == "testDone":
                test_id = event.get("testID")
                if test_id is not None and test_id in tests:
                    tests[test_id]["result"] = event.get("result", "error")
                    end_time = event.get("time", start_times.get(test_id, 0))
                    tests[test_id]["duration_ms"] = (
                        end_time - start_times.get(test_id, end_time)
                    )
                    # エラー情報をマージ
                    if test_id in errors:
                        tests[test_id]["error"] = errors[test_id]["error"]
                        tests[test_id]["stackTrace"] = errors[test_id]["stackTrace"]

            elif event_type == "error":
                test_id = event.get("testID")
                if test_id is not None:
                    errors[test_id] = {
                        "error": event.get("error", ""),
                        "stackTrace": event.get("stackTrace", ""),
                    }
                    if test_id in tests:
                        tests[test_id]["error"] = errors[test_id]["error"]
                        tests[test_id]["stackTrace"] = errors[test_id]["stackTrace"]

    return tests


def build_junit_xml(tests: dict, suite_name: str = "FlutterTests") -> ET.Element:
    """テスト結果辞書から JUnit XML の ElementTree を構築する。"""
    # グループ(suite)なしの場合は全テストを1つのテストスイートにまとめる
    total = len(tests)
    failures = sum(1 for t in tests.values() if t.get("result") in ("failure", "error"))
    errors = sum(1 for t in tests.values() if t.get("result") is None)
    total_time = sum(t.get("duration_ms", 0) for t in tests.values()) / 1000.0

    testsuite = ET.Element("testsuite")
    testsuite.set("name", suite_name)
    testsuite.set("tests", str(total))
    testsuite.set("failures", str(failures))
    testsuite.set("errors", str(errors))
    testsuite.set("time", f"{total_time:.3f}")
    testsuite.set("timestamp", datetime.utcnow().isoformat())

    for test_id, info in tests.items():
        # [loading] など内部テストは除外する
        name = info["name"]
        if name.startswith("loading ") or name == "loading":
            continue

        tc = ET.SubElement(testsuite, "testcase")
        # テスト名からクラス名(グループ)と名前を分離する（Flutter は " " 区切り）
        parts = name.split(" ", 1)
        classname = parts[0] if len(parts) > 1 else suite_name
        tc.set("classname", classname)
        tc.set("name", name)
        tc.set("time", f"{info.get('duration_ms', 0) / 1000.0:.3f}")

        result = info.get("result")
        if result in ("failure", "error") or result is None:
            failure_el = ET.SubElement(tc, "failure")
            err_msg = info.get("error") or "テスト失敗"
            stack = info.get("stackTrace") or ""
            failure_el.set("message", err_msg)
            failure_el.text = f"{err_msg}\n\n{stack}".strip()

    return testsuite


def prettify(element: ET.Element) -> str:
    """ET.Element を整形された XML 文字列に変換する。"""
    raw = ET.tostring(element, encoding="unicode")
    dom = minidom.parseString(raw)
    return dom.toprettyxml(indent="  ")


def main():
    if len(sys.argv) < 3:
        print(f"使い方: {sys.argv[0]} <input.json> <output.xml>", file=sys.stderr)
        sys.exit(1)

    input_path = Path(sys.argv[1])
    output_path = Path(sys.argv[2])

    output_path.parent.mkdir(parents=True, exist_ok=True)

    tests = parse_flutter_json(input_path)

    if not tests:
        # 入力なし or 解析失敗 → 空の XML を出力してパイプラインを止めない
        print(f"警告: {input_path} からテスト結果を読み込めませんでした。空の XML を生成します。")
        root = ET.Element("testsuite")
        root.set("name", "FlutterTests")
        root.set("tests", "0")
        root.set("failures", "0")
        root.set("errors", "0")
        root.set("time", "0.000")
        root.set("timestamp", datetime.utcnow().isoformat())
        xml_str = prettify(root)
    else:
        root = build_junit_xml(tests)
        xml_str = prettify(root)
        total = root.get("tests", "0")
        failures = root.get("failures", "0")
        print(f"変換完了: {total} テスト, {failures} 失敗 → {output_path}")

    output_path.write_text(xml_str, encoding="utf-8")


if __name__ == "__main__":
    main()
