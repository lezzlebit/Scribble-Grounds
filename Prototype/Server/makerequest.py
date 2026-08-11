import requests


headers = {'Content-type': 'image/png'}
test_image = open("test_image.png", "rb").read()

r = requests.post("http://localhost:8000/", test_image, headers=headers)
print(r.status_code)
print(r.content)