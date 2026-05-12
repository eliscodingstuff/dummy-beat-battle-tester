import asyncio
import websockets
import json
import os
import zipfile
import time
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class DownloadWatcher(FileSystemEventHandler):
    def __init__(self, target_filename, callback):
        self.target_filename = target_filename
        self.callback = callback
        self.found = False

    def on_created(self, event):
        if event.is_directory:
            return

        filename = os.path.basename(event.src_path)
        if filename == self.target_filename and not self.found:
            self.found = True
            self.callback(event.src_path)

class AutoLocSamples:
    def __init__(self):
        self.downloads_folder = str(Path.home() / "Downloads")
        self.active_watches = {}

    async def handle_client(self, websocket, path):
        print(f"Client connected from {websocket.remote_address}")

        try:
            async for message in websocket:
                data = json.loads(message)
                print(f"Received: {data}")

                if data.get('action') == 'watch_and_extract':
                    await self.watch_and_extract(
                        websocket,
                        data.get('filename'),
                        data.get('destination')
                    )

        except websockets.exceptions.ConnectionClosed:
            print("Client disconnected")
        except Exception as e:
            print(f"Error: {e}")
            await websocket.send(json.dumps({
                'status': 'error',
                'code': 'UNKNOWN_ERROR',
                'message': str(e)
            }))

    async def watch_and_extract(self, websocket, filename, destination):
        if not filename:
            await websocket.send(json.dumps({
                'status': 'error',
                'code': 'MISSING_FILENAME',
                'message': 'Filename is required'
            }))
            return

        if not destination:
            await websocket.send(json.dumps({
                'status': 'error',
                'code': 'MISSING_DESTINATION',
                'message': 'Destination folder is required'
            }))
            return

        if not os.path.exists(destination):
            await websocket.send(json.dumps({
                'status': 'error',
                'code': 'INVALID_DESTINATION',
                'message': f'Destination folder does not exist: {destination}'
            }))
            return

        print(f"Watching for {filename} in {self.downloads_folder}")
        await websocket.send(json.dumps({
            'status': 'watching',
            'message': f'Watching for {filename}...'
        }))

        # Check if file already exists
        zip_path = os.path.join(self.downloads_folder, filename)
        if os.path.exists(zip_path):
            print(f"File already exists: {zip_path}")
            await self.extract_zip(websocket, zip_path, destination, filename)
            return

        # Set up file watcher
        file_found = asyncio.Event()
        found_path = None

        def on_file_found(path):
            nonlocal found_path
            found_path = path
            file_found.set()

        event_handler = DownloadWatcher(filename, on_file_found)
        observer = Observer()
        observer.schedule(event_handler, self.downloads_folder, recursive=False)
        observer.start()

        try:
            # Wait up to 10 seconds for the file
            await asyncio.wait_for(file_found.wait(), timeout=10.0)

            # Give a small delay for file to finish downloading
            await asyncio.sleep(0.5)

            print(f"File found: {found_path}")
            await self.extract_zip(websocket, found_path, destination, filename)

        except asyncio.TimeoutError:
            print(f"Timeout waiting for {filename}")
            await websocket.send(json.dumps({
                'status': 'error',
                'code': 'TIMEOUT',
                'message': f'File {filename} did not appear in Downloads folder within 10 seconds'
            }))
        finally:
            observer.stop()
            observer.join()

    async def extract_zip(self, websocket, zip_path, destination, filename):
        try:
            # Wait for file to be fully downloaded (check if still being written)
            max_wait = 5
            wait_count = 0
            last_size = -1

            while wait_count < max_wait:
                try:
                    current_size = os.path.getsize(zip_path)
                    if current_size == last_size and current_size > 0:
                        break
                    last_size = current_size
                    await asyncio.sleep(0.5)
                    wait_count += 0.5
                except:
                    await asyncio.sleep(0.5)
                    wait_count += 0.5

            # Create directory name from zip filename (without .zip extension)
            folder_name = os.path.splitext(filename)[0]
            extract_path = os.path.join(destination, folder_name)

            # Create directory if it doesn't exist
            os.makedirs(extract_path, exist_ok=True)

            print(f"Extracting {zip_path} to {extract_path}")
            await websocket.send(json.dumps({
                'status': 'extracting',
                'message': f'Extracting to {extract_path}...'
            }))

            # Extract the zip file
            with zipfile.ZipFile(zip_path, 'r') as zip_ref:
                zip_ref.extractall(extract_path)

            print(f"Extraction complete: {extract_path}")
            await websocket.send(json.dumps({
                'status': 'success',
                'message': f'Successfully extracted to {extract_path}',
                'extract_path': extract_path
            }))

        except zipfile.BadZipFile:
            await websocket.send(json.dumps({
                'status': 'error',
                'code': 'INVALID_ZIP',
                'message': f'File is not a valid zip archive: {filename}'
            }))
        except PermissionError:
            await websocket.send(json.dumps({
                'status': 'error',
                'code': 'PERMISSION_DENIED',
                'message': f'Permission denied when extracting to {destination}'
            }))
        except Exception as e:
            await websocket.send(json.dumps({
                'status': 'error',
                'code': 'EXTRACTION_ERROR',
                'message': f'Error extracting zip: {str(e)}'
            }))

    async def start_server(self, host='localhost', port=8765):
        print(f"AutoLocSamples server starting on ws://{host}:{port}")
        print(f"Monitoring downloads folder: {self.downloads_folder}")

        async with websockets.serve(self.handle_client, host, port):
            print("Server ready. Waiting for connections...")
            await asyncio.Future()  # Run forever

def main():
    app = AutoLocSamples()
    try:
        asyncio.run(app.start_server())
    except KeyboardInterrupt:
        print("\nShutting down server...")

if __name__ == "__main__":
    main()
