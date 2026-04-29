"""
App Store Connect API helper
Usage: python appstore_api.py <action>
"""
import jwt
import time
import json
import urllib.request
import urllib.error
import sys

# Credentials
ISSUER_ID = "5325aa4e-8a81-4662-94d3-83961c7e1151"
KEY_ID = "5WHQMRJ2GT"
KEY_FILE = r"C:\Users\AsusGaming\Downloads\AuthKey_5WHQMRJ2GT.p8"

def generate_token():
    with open(KEY_FILE, "r") as f:
        private_key = f.read()

    now = int(time.time())
    payload = {
        "iss": ISSUER_ID,
        "iat": now,
        "exp": now + 1200,  # 20 minutes
        "aud": "appstoreconnect-v1"
    }

    token = jwt.encode(
        payload,
        private_key,
        algorithm="ES256",
        headers={"kid": KEY_ID, "typ": "JWT"}
    )
    return token

def api_request(method, path, data=None):
    token = generate_token()
    url = f"https://api.appstoreconnect.apple.com/v1/{path}"

    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json"
    }

    if data:
        req = urllib.request.Request(url, data=json.dumps(data).encode(), headers=headers, method=method)
    else:
        req = urllib.request.Request(url, headers=headers, method=method)

    try:
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode())
    except urllib.error.HTTPError as e:
        error_body = e.read().decode()
        print(f"Error {e.code}: {error_body}")
        return None

def list_apps():
    result = api_request("GET", "apps")
    if result:
        apps = result.get("data", [])
        if not apps:
            print("No apps found.")
        for app in apps:
            attrs = app["attributes"]
            print(f"  {attrs['name']} ({attrs['bundleId']}) - {attrs.get('sku', 'N/A')}")
    return result

def list_bundle_ids():
    result = api_request("GET", "bundleIds")
    if result:
        ids = result.get("data", [])
        if not ids:
            print("No Bundle IDs registered.")
        for bid in ids:
            attrs = bid["attributes"]
            print(f"  {attrs['identifier']} ({attrs['platform']}) - ID: {bid['id']}")
    return result

def register_bundle_id(identifier, name, platform="IOS"):
    data = {
        "data": {
            "type": "bundleIds",
            "attributes": {
                "identifier": identifier,
                "name": name,
                "platform": platform
            }
        }
    }
    result = api_request("POST", "bundleIds", data)
    if result:
        print(f"Bundle ID registered: {identifier}")
    return result

def create_app(name, bundle_id_resource_id, sku, locale="zh-Hant"):
    data = {
        "data": {
            "type": "apps",
            "attributes": {
                "bundleId": bundle_id_resource_id,
                "name": name,
                "primaryLocale": locale,
                "sku": sku
            },
            "relationships": {
                "bundleId": {
                    "data": {
                        "type": "bundleIds",
                        "id": bundle_id_resource_id
                    }
                }
            }
        }
    }
    # App creation uses a different endpoint structure
    result = api_request("POST", "apps", data)
    if result:
        print(f"App created: {name}")
    return result

def test_connection():
    print("Testing API connection...")
    token = generate_token()
    print(f"Token generated: {token[:50]}...")

    result = api_request("GET", "apps")
    if result is not None:
        print("API connection successful!")
        apps = result.get("data", [])
        print(f"Found {len(apps)} app(s)")
        return True
    else:
        print("API connection failed!")
        return False

if __name__ == "__main__":
    action = sys.argv[1] if len(sys.argv) > 1 else "test"

    if action == "test":
        test_connection()
    elif action == "list":
        list_apps()
    elif action == "bundles":
        list_bundle_ids()
    elif action == "register":
        register_bundle_id("com.cleanupmaster.app", "CleanupMaster", "IOS")
    elif action == "create":
        create_app("清理大師", "com.cleanupmaster.app", "CLEANUPMASTER001")
    else:
        print(f"Unknown action: {action}")
