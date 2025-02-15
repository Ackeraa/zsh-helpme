aip_key="sk-L9779Qjw8OyxX3X3BWLGMoQLbPLitxcgtRXDLNI93XZpWotd"
current_input="cd"
history=`history`
prompt="Based on this command history:\n$history\n\nAnd current input: $current_input\nSuggest completion for: $current_input"

suggestion=$(curl -s -H "Content-Type: application/json" \
    -H "Authorization: Bearer $aip_key" \
    -d "{
    \"messages\": [
        {
        \"role\": \"system\",
        \"content\": \"You are a helpful linux command-line assistant. Provide brief, direct command completions.\"
        },
        {
        \"role\": \"user\",
        \"content\": \"$prompt\"
        }
    ],
    \"stream\": false,
    \"model\": \"gpt-3.5-turbo\",
    \"temperature\": 0.5,
    \"presence_penalty\": 0,
    \"frequency_penalty\": 0,
    \"top_p\": 1
    }" \
    "https://xiaoai.plus/v1/chat/completions" | jq -r '.choices[0].message.content')

echo $suggestion