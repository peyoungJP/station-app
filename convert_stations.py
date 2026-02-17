import csv
import uuid

PREF_MAP = {
    '1': '北海道', '2': '青森県', '3': '岩手県', '4': '宮城県', '5': '秋田県',
    '6': '山形県', '7': '福島県', '8': '茨城県', '9': '栃木県', '10': '群馬県',
    '11': '埼玉県', '12': '千葉県', '13': '東京都', '14': '神奈川県', '15': '新潟県',
    '16': '富山県', '17': '石川県', '18': '福井県', '19': '山梨県', '20': '長野県',
    '21': '岐阜県', '22': '静岡県', '23': '愛知県', '24': '三重県', '25': '滋賀県',
    '26': '京都府', '27': '大阪府', '28': '兵庫県', '29': '奈良県', '30': '和歌山県',
    '31': '鳥取県', '32': '島根県', '33': '岡山県', '34': '広島県', '35': '山口県',
    '36': '徳島県', '37': '香川県', '38': '愛媛県', '39': '高知県', '40': '福岡県',
    '41': '佐賀県', '42': '長崎県', '43': '熊本県', '44': '大分県', '45': '宮崎県',
    '46': '鹿児島県', '47': '沖縄県',
}

# Load line data (line_cd -> line_name)
line_map = {}
with open('tmp_lines.txt', 'r', encoding='utf-8') as f:
    for line in f:
        if line.startswith('#') or not line.strip():
            continue
        parts = line.strip().split('\t')
        if len(parts) >= 4:
            line_cd = parts[1]  # line_cd
            line_name = parts[3]  # line_name
            line_map[line_cd] = line_name

# Load and convert station data
stations = []
with open('tmp_stations.txt', 'r', encoding='utf-8') as f:
    for line in f:
        if line.startswith('#') or not line.strip():
            continue
        parts = line.strip().split('\t')
        # Columns: idx, station_cd, station_name, station_name_k, station_name_r,
        #          line_cd, pref_cd, post, add, lon, lat, open_ymd, close_ymd, e_status, e_sort
        if len(parts) < 11:
            continue

        station_name = parts[3]  # station_name
        line_cd = parts[6]       # line_cd
        pref_cd = parts[7]       # pref_cd
        lon = parts[10]          # lon
        lat = parts[11]          # lat

        # Skip if no coordinates
        if not lon or not lat:
            continue

        try:
            lat_f = float(lat)
            lon_f = float(lon)
        except ValueError:
            continue

        # Skip invalid coordinates
        if lat_f == 0 or lon_f == 0:
            continue

        prefecture = PREF_MAP.get(pref_cd, '')
        line_name = line_map.get(line_cd, '')

        if not prefecture or not line_name:
            continue

        stations.append({
            'id': str(uuid.uuid4()),
            'name': station_name,
            'latitude': lat_f,
            'longitude': lon_f,
            'prefecture': prefecture,
            'line_name': line_name,
        })

# Write CSV for Supabase import
with open('stations_import.csv', 'w', encoding='utf-8', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['id', 'name', 'latitude', 'longitude', 'prefecture', 'line_name'])
    for s in stations:
        writer.writerow([s['id'], s['name'], s['latitude'], s['longitude'], s['prefecture'], s['line_name']])

print(f"Total stations exported: {len(stations)}")
