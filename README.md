# Radios

If you want to run on port 8080 do

```
$ docker build --tag=radioapp .

$ docker run -p 8080:80 radioapp
```

Otherwise just run with `mix`
```
$ mix deps.get
$ mix compile
$ PORT=8080 mix run --no-halt
```
