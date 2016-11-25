# Recommendations Formula
eLife Recommendations formula (deliverable for SA)

**Deliverables:**
- Silex application setup configuration (likely adapted from search) - Could we pull in the base silex app for now ?
  - nginx
  - php7
  - proofreader
- Queue watching SQS
- Database (tbd) -  https://github.com/elifesciences/builder-base-formula/tree/master/elife already has a Mysql 5.7 and Redis stack file :D
- Initial set up (likely adapted from searchs' import:all command)


**Green builds**
If we are running commands that don't exist yet, we can use pillar configuration as feature flags to turn off different commands until they are created.

**Subjects to be discussed**
- Caching Strategy
- Read/write perfomance
- Maintainablity (Comparison of utilising AWS offerings VS self hosted within EC2)
