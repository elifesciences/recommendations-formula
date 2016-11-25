# Redis case study
Note: For testing I'm using a latest tag of official redis from docker and running 
`$ redis-cli` from inside the shell and running the commands.


## 1) Simple questions

### What articles are related to article<1> with rule "my_rule" with most recent first?

Example of JSON set inserts (Note timestamp)
```redis
> ZADD articles:my_rule:1 1479462111 '{"type": "article", "id": 2}'
> ZADD articles:my_rule:1 1379462114 '{"type": "article", "id": 3}'
> ZADD articles:my_rule:1 1579462114 '{"type": "article", "id": 4}'
```

Example of querying back results
```redis
> ZREVRANGE articles:my_rule:1 0 -1
"{"type": "article", "id": 4}"
"{"type": "article", "id": 2}"
"{"type": "article", "id": 3}"
```
