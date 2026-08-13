import asyncio
import websockets

connected_clients = set()

async def handle_client(websocket):
	connected_clients.add(websocket)
	try:
		async for message in websocket:
			for client in connected_clients.copy():
				print(message)
				client.send("nooopeeee")
				if client != websocket:
					try:
						await client.send(message)
					except:
						
						pass
	except websockets.exceptions.ConnectionClosed:
		pass
	finally:
		connected_clients.remove(websocket)

def process_request(connection, request):
	print(request)

async def main():
	server = await websockets.serve(handle_client, 'localhost', 12345, process_request=process_request)
	await server.wait_closed()

if __name__ == "__main__":
	asyncio.run(main())