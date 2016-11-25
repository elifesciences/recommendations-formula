# Domain and flow of application

## User requesting recommendation

### Routing / bootstrap
Silex starter kit with simple routes and argument parsing.

### Content type
Similar to Medium API for request type and similar to search for response type (JMS).

### Requesting
Will be using a rules system (see TASKS.md)

### Hydrating [type, id]
See DATABASE.md

### Building and returning valid response
JMS serializer like search with eLife PHP Validator

## Application inserting new recommendation

### Console / command bootstrap
Silex starter kit.

### Content type rule sets
Note: Selecting which set of rules to apply when a new item comes in.

### Persisting rule results
See DATABASE.md.

### Transforming rule results into relations
See DATABASE.md.

### Data integrity
- How we will ensure that the relations are always up to date at any given time.
- Which cases will we deprioritise data integrity

See DATABASE.md.

## Initial setup

### Long running process
PHP Console commands with safeguards from search

### Snapshots
- When logic changes and we need to rebuild, how will we ensure that the graph is built back up quickly.
