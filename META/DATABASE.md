# Database options

## Considerations
User requests wont be writing to the database so the focus for efficiency can be read speeds.
For each rule we have we are asking a single question of our data, and expecting
a standard set of items (type + id). There is two clear solutions to choose from
described here. 

A relational database will provide us with a "dumb" data and "smart" queries 
solution. The smart queries (joins/sub-queries) will build the datasets for us at
run time. The dumb data will simplify the building of the data-model. Upserts will
be trivial and standard across rules.

A NoSQL solution will provide us with a "smart" data and "dumb" queries solution.
The dumb queries (simple scans or key fetches) will return re-built datasets for 
us, speeding up reads. The smart data will have to be pre-built sets of relations. 
Upserts will be more challenging than relational, but many rules will use the same
logic.

## Deliverables
- Salt files for chosen technology
- Breakdown of the pros and cons of each approach.
- Cross examination with rules and any risks with either approach.

## Relational (MySQL and/or other >?)

### Pros
- MySQL salt file already in existence and being used by other micro-services, it is also upto date (MySQL 5.7 :D)
- Ability to maintain data integrity during pruning and upserts via foreign keys
- Less application logic required as MySQL has more operations available
- ACID Compliant
- Locking built in
- Transactions
- More natural segregation of data using differing tables etc

### Cons
- Performance less than that of Non Relational (Read/Writes)
- Does not naturally handle JSON documents, although does have a JSON data type. It's not ideal to have JSON stored in one big field within a row
- Limited Database level JSON operations/functions
- Development time longer due to large data-model w/ queries to create

## Key Value ( Redis vs Mongo vs DynamoDB and/or other >?)

### Pros
- Salt stack already available for Redis, Mongo TBC, DynamoDB is hosted and used by other services
- Improved performance over MySQL
- Natural JSON handling (Mongo/DyDB)
- Simplified query / reads.

### Cons
- Not ACID (@Ross inserts single threaded)
- Locking would have to be at application level (@Ross inserts single threaded)
- Support for transactions dependant on flavour (@Ross idempotent upserts/sets will avoid this)
- Data integrity becomes an Application problem (Deletions are the biggest problems)
- Longer data-model planning

## Decision
