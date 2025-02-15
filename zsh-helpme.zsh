#--------------------------------------------------------------------#
# Global Configuration Variables                                     #
#--------------------------------------------------------------------#

# Color to use when highlighting suggestions
(( ! ${+ZSH_HELPME_COLOR} )) &&
typeset -g ZSH_HELPME_COLOR="fg=8"

# API endpoint for AI suggestions (default: OpenAI)
(( ! ${+ZSH_HELPME_API_ENDPOINT} )) &&
typeset -g ZSH_HELPME_API_ENDPOINT="https://api.openai.com/v1/completions"

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
           \"model\": \"gpt-3.5-turbo\",
           \"prompt\": \"$prompt\",
           \"max_tokens\": 50,
           \"temperature\": 0.7
         }" \
         "$ZSH_HELPME_API_ENDPOINT" | jq -r '.choices[0].text')
    
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
            local colored_suggestion="%F{$ZSH_HELPME_COLOR}${suggestion}%f"
            
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

