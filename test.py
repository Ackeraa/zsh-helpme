import http.client
import json

conn = http.client.HTTPSConnection("xiaoai.plus")
payload = json.dumps({
   "messages": [
      {
         "role": "system",
         "content": "你是一个大语言模型机器人"
      },
      {
         "role": "user",
         "content": "你好"
      }
   ],
   "stream": False,
   "model": "gpt-3.5-turbo",
   "temperature": 0.5,
   "presence_penalty": 0,
   "frequency_penalty": 0,
   "top_p": 1
})
headers = {
   'Authorization': 'Bearer ',
   'Content-Type': 'application/json'
}
conn.request("POST", "/v1/chat/completions", payload, headers)
res = conn.getresponse()
data = res.read()
print(data.decode("utf-8"))