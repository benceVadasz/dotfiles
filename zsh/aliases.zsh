# Development aliases
alias dev="cd ~/Desktop/Dev"
alias play="cd ~/Desktop/Dev/playground"
alias pjob="pbpaste > ~/Desktop/Dev/projects/jobs-api/content.txt"
alias particle="pbpaste > ~/Desktop/Dev/projects/AICommands/article/content.txt"
alias article='node ~/Desktop/Dev/projects/AICommands/article/index.js'

# Docker related aliases
alias seed='yarn b docker:exec seed'
alias migration-run='yarn b docker:exec migration:run'
alias dock="docker exec -ti ev-backend yarn"
alias restart="yarn docker:reset && yarn start:dev:build && docker exec -ti ev-backend yarn seed"

# Database proxies
alias start-prod-proxy='cloud-sql-proxy ev-remarketing-production:europe-west1:cloudrun-sql --port 5434'
alias start-staging-proxy='cloud-sql-proxy ev-remarketing-staging:europe-west1:cloudrun-sql --port 5433'

# Utility aliases
alias clear-photos="~/.config/scripts/clear_photos.sh"
alias myip="ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print \$2}'"
alias config="code ~/.zshrc"
alias photos-size="du -h ~/Desktop/kvalifik/ev-remarketing/backend/public/storage/photos/"
alias pp="git reset HEAD~1 && gst && gpl && gstp"alias testdot="echo dotfiles are working!"
