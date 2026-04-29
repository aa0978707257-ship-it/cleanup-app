"""Upload screenshots to App Store Connect"""
from scripts.appstore_api import api_request, generate_token
import json
import os
import hashlib
import urllib.request

SCREENSHOT_SET_ID = '7447c25a-d65f-4d5d-86a6-a2d4989fb562'

def upload_screenshot(file_path, file_name):
    file_size = os.path.getsize(file_path)

    # Step 1: Reserve screenshot
    data = {
        'data': {
            'type': 'appScreenshots',
            'attributes': {
                'fileName': file_name,
                'fileSize': file_size
            },
            'relationships': {
                'appScreenshotSet': {
                    'data': {
                        'type': 'appScreenshotSets',
                        'id': SCREENSHOT_SET_ID
                    }
                }
            }
        }
    }

    result = api_request('POST', 'appScreenshots', data)
    if not result:
        print(f'Failed to reserve {file_name}')
        return False

    screenshot_id = result['data']['id']
    upload_ops = result['data']['attributes'].get('uploadOperations', [])
    print(f'Reserved: {screenshot_id}, {len(upload_ops)} upload operations')

    # Step 2: Upload file parts
    with open(file_path, 'rb') as f:
        file_data = f.read()

    for op in upload_ops:
        url = op['url']
        offset = op['offset']
        length = op['length']
        headers_list = op['requestHeaders']

        chunk = file_data[offset:offset + length]

        req = urllib.request.Request(url, data=chunk, method='PUT')
        for h in headers_list:
            req.add_header(h['name'], h['value'])

        try:
            with urllib.request.urlopen(req) as resp:
                pass
            print(f'  Uploaded chunk: offset={offset}, length={length}')
        except Exception as e:
            print(f'  Upload failed: {e}')
            return False

    # Step 3: Commit
    md5 = hashlib.md5(file_data).hexdigest()
    source_length = len(file_data)

    commit_data = {
        'data': {
            'type': 'appScreenshots',
            'id': screenshot_id,
            'attributes': {
                'uploaded': True,
                'sourceFileChecksum': md5
            }
        }
    }

    result = api_request('PATCH', f'appScreenshots/{screenshot_id}', commit_data)
    if result:
        state = result['data']['attributes'].get('assetDeliveryState', {}).get('state', 'unknown')
        print(f'Committed: {file_name} (state: {state})')
        return True
    else:
        print(f'Commit failed for {file_name}')
        return False

if __name__ == '__main__':
    base = r'C:\Users\AsusGaming\cleanup_flutter'
    screenshots = [
        (os.path.join(base, 'screenshot_1.png'), 'screenshot_1.png'),
        (os.path.join(base, 'screenshot_2.png'), 'screenshot_2.png'),
        (os.path.join(base, 'screenshot_3.png'), 'screenshot_3.png'),
    ]

    for path, name in screenshots:
        print(f'\nUploading {name}...')
        upload_screenshot(path, name)

    print('\nDone!')
