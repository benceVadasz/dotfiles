# zsh/functions.zsh
killport() {
  if [[ -z $1 ]]; then
    echo "Usage: killport <port>"
    return 1
  fi

  local port=$1
  local pids=$(lsof -t -i:$port)

  if [[ -z $pids ]]; then
    echo "No processes found on port $port."
    return 1
  fi

  echo "Killing processes on port $port: $pids"
  kill -9 $pids
}

migration-gen() {
  docker exec -ti ev-backend yarn migration:generate "$1"
}

job() {
  node ~/Desktop/Dev/projects/jobs-api/index.js "$1" "$2"
}

checkout_branch() {
  echo "Checking out branch $1"
  git checkout "$1"
}