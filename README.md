# TaskHandler

This is a simple dependency handler application that builds an `execution_plan` based on a list of tasks.

It provides a single endpoint `POST /api/execution_plans` that accepts a list of tasks as in the following example:
```json
{
  "tasks": [
    {"name": "task_g", "command": "rm -r tmp", "requires": ["task_f"]},
    {"name": "task_c", "command": "touch one_plus_one.exs", "requires": ["task_b"]},
    {"name": "task_e", "command": "elixir one_plus_one.exs", "requires": ["task_d"]},
    {"name": "task_b", "command": "cd tmp", "requires": ["task_a"]},
    {"name": "task_f", "command": "cd ..", "requires": ["task_e"]},
    {"name": "task_a", "command": "mkdir ./tmp"},
    {"name": "task_d", "command": "echo 'IO.puts(1 + 1)' >> one_plus_one.exs", "requires": ["task_c"]}
  ]
}
```

```sh
curl http://localhost:4000/api/execution_plans -d @tasks.json -H 'Content-Type: application/json' -H 'Accept: application/json' | jq .
```

```json
[
  {
    "command": "mkdir ./tmp",
    "name": "task_a"
  },
  {
    "command": "cd tmp",
    "name": "task_b"
  },
  {
    "command": "touch one_plus_one.exs",
    "name": "task_c"
  },
  {
    "command": "echo 'IO.puts(1 + 1)' >> one_plus_one.exs",
    "name": "task_d"
  },
  {
    "command": "elixir one_plus_one.exs",
    "name": "task_e"
  },
  {
    "command": "cd ..",
    "name": "task_f"
  },
  {
    "command": "rm -r tmp",
    "name": "task_g"
  }
]
```

You can also change the `Accept` header to `application/x-sh` and receive a shell script back from the api:

```sh
curl http://localhost:4000/api/execution_plans -d @tasks.json -H 'Content-Type: application/json' -H 'Accept: application/x-sh' | sh
```

## Running the server with docker:
- build: `docker image build -t task_handler`
- run server: `docker container run -e SECRET_KEY_BASE=foo --rm -it -p 127.0.0.1:4000:4000 --name app task_handler`

```
curl http://localhost:4000/api/execution_plans -d '{"tasks": [{"name": "task_a", "command": "ls"}]}' -H 'Content-Type: application/json' -H 'Accept: application/x-sh' | sh
```
