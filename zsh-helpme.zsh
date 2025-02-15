#--------------------------------------------------------------------#
# Global Configuration Variables                                     #
#--------------------------------------------------------------------#

# Color to use when highlighting suggestions
(( ! ${+ZSH_HELPME_COLOR} )) &&
typeset -g ZSH_HELPME_COLOR="fg=8"

# API endpoint for AI suggestions (default: OpenAI)
(( ! ${+ZSH_HELPME_API_ENDPOINT} )) &&
typeset -g ZSH_HELPME_API_ENDPOINT=""

# API key for the AI service
(( ! ${+ZSH_HELPME_API_KEY} )) &&
typeset -g ZSH_HELPME_API_KEY=""

#--------------------------------------------------------------------#
# Utility Functions                                                  #
#--------------------------------------------------------------------#

# Get command history
_zsh_helpme_get_history() {
    local last_commands
    last_commands=(${(f)"$(fc -ln -10)"})
    echo $last_commands
}

# Get AI suggestion
_zsh_helpme_get_suggestion() {
    local current_input=$1
    local history=$(_zsh_helpme_get_history)
    
    # Prepare the prompt for AI
    local prompt="Based on this command history:\n$history\n\nAnd current input: $current_input\nSuggest completion for: $current_input"
    
    # Call AI API (using curl)
    local suggestion=$(curl -s -H "Content-Type: application/json" \
        -H "Authorization: Bearer $ZSH_HELPME_API_KEY" \
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
        "$ZSH_HELPME_API_ENDPOINT" | jq -r '.choices[0].message.content')

    echo $suggestion
}

# Display suggestion
_zsh_helpme_suggest() {
    local current_buffer=$BUFFER
    
    # Only get suggestion if buffer is not empty
    if [[ -n "$current_buffer" ]]; then
        local suggestion=$(_zsh_helpme_get_suggestion "$current_buffer")
        
        if [[ -n "$suggestion" ]]; then
            # Display suggestion in the configured color
            local colored_suggestion=$suggestion
            
            # Show suggestion to the right of the cursor
            POSTDISPLAY="$colored_suggestion"
        fi
    fi
}

# Initialize plugin
_zsh_helpme_init() {
    # Add our suggestion widget
    zle -N _zsh_helpme_widget _zsh_helpme_suggest
    
    # Bind widget to key (default: right arrow)
    bindkey '`' _zsh_helpme_widget
}

# Start the plugin
_zsh_helpme_init

