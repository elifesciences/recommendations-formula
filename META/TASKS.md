The Tasks
=========

1. [Retraction articles for this article](#retraction-articles-for-this-article)
2. [Correction articles for this article](#correction-articles-for-this-article)
3. [Articles an Insight, Feature, Editorial, Research Advance, Research Exchange or Registered Report, Retraction or Correction is linked to](#articles-an-insight--feature--editorial--research-advance--research-exchange-or-registered-report--retraction-or-correction-is-linked-to)
4. [Research Advance articles that are linked to this article](#research-advance-articles-that-are-linked-to-this-article)
5. [Research Exchange articles that are linked to this article](#research-exchange-articles-that-are-linked-to-this-article)
6. [Research Articles that are linked to this article](#research-articles-that-are-linked-to-this-article)
7. [Tools and Resources articles that are linked to this article](#tools-and-resources-articles-that-are-linked-to-this-article)
8. [Feature articles that are linked to this article](#feature-articles-that-are-linked-to-this-article)
9. [Insight articles that are linked to this article](#insight-articles-that-are-linked-to-this-article)
10. [Editorial articles that are linked to this article](#editorial-articles-that-are-linked-to-this-article)
11. [Collections that contain this article](#collections-that-contain-this-article)
12. [Podcast episodes that contain this article](#podcast-episodes-that-contain-this-article)
13. [Most recent article, collection or podcast episode with the same first subject](#most-recent-article--collection-or-podcast-episode-with-the-same-first-subject)
14. [Most recent Research Advance, Research Article, Research Exchange, Short Report, Tools and](#most-recent-research-advance--research-article--research-exchange--short-report--tools-and)
15. [Resources or Replication Study article](#resources-or-replication-study-article)


### Retraction articles for this article
Example Input
```json
{}
```

Example Output
```json
{}
```


### Correction articles for this article
Example Input
```json
{}
```

Example Output
```json
{}
```


### Articles an Insight, Feature, Editorial, Research Advance, Research Exchange or Registered Report, Retraction or Correction is linked to
Example Input
```json
{}
```

Example Output
```json
{}
```

### Research Advance articles that are linked to this article
Example Input
```json
{}
```

Example Output
```json
{}
```


### Research Exchange articles that are linked to this article
Example Input
```json
{}
```

Example Output
```json
{}
```


### Research Articles that are linked to this article
Example Input
```json
{}
```

Example Output
```json
{}
```


### Tools and Resources articles that are linked to this article
Example Input
```json
{}
```

Example Output
```json
{}
```


### Feature articles that are linked to this article
Example Input
```json
{}
```

Example Output
```json
{}
```


### Insight articles that are linked to this article
Example Input
```json
{}
```

Example Output
```json
{}
```


### Editorial articles that are linked to this article
Example Input
```json
{}
```

Example Output
```json
{}
```


### Collections that contain this article
Example Input
```json
{}
```

Example Output
```json
{}
```


### Podcast episodes that contain this article
Example Input
```json
{
    "number": 1,
    "title": "June 2013",
    "..." : "...",
    "chapters": [
        {
            "number": 1,
            "title": "The pleasure of publishing",
            "time": 0,
            "impactStatement": "When assessing manuscripts eLife editors look for a combination of rigour and insight, along with results and ideas that make other researchers think differently about their subject.",
            "content": [
                {
                    "status": "vor",
                    "id": "05770",
                    "version": 1,
                    "type": "editorial",
                    "image": {
                        "thumbnail": {
                            "alt": "",
                            "sizes": {
                                "16:9": {
                                    "250": "http://demo--api-dummy.elifesciences.org/images/articles/05770/jpg?width=250&height=141",
                                    "500": "http://demo--api-dummy.elifesciences.org/images/articles/05770/jpg?width=500&height=281"
                                },
                                "1:1": {
                                    "70": "http://demo--api-dummy.elifesciences.org/images/articles/05770/jpg?width=70&height=70",
                                    "140": "http://demo--api-dummy.elifesciences.org/images/articles/05770/jpg?width=140&height=140"
                                }
                            }
                        }
                    },
                    "doi": "10.7554/eLife.05770",
                    "title": "The pleasure of publishing",
                    "published": "2015-01-06T00:00:00Z",
                    "statusDate": "2016-03-28T00:00:00Z",
                    "volume": 5,
                    "elocationId": "e05770",
                    "authorLine": "Vivek Malhotra, Eve Marder",
                    "pdf": "https://elifesciences.org/content/4/e05770.pdf",
                    "impactStatement": "When assessing manuscripts eLife editors look for a combination of rigour and insight, along with results and ideas that make other researchers think differently about their subject."
                }
            ]
        }
    ]
}
```

Example Output
```json
[
    {
        "subject": {"type": "podcast", "id": 1},
        "on": {"type": "article", "id": "05770"},
    }
]
```

Example KVS key:
```
article.05770.contains_podcast.1] => type podcast-episode id 1

```

Example Query:
```
article.05770.* => [{"type": "podcast-episode", "id": 1}]
```

Example MySQL:
```SQL
INSERT INTO podcast_episode_articles (subject_type, subject_id, on_type, on_id) VALUES ("podcast", "1", "article", "05770");
```

Example MySQL Query:
```SQL
SELECT subject_type, subject_id FROM podcast_episode_articles WHERE on_id="057770"
```


### Most recent article, collection or podcast episode with the same first subject

Example Input
```json
{}
```

Example Output
```json
{}
```


### Most recent Research Advance, Research Article, Research Exchange, Short Report, Tools and
Example Input
```json
{}
```

Example Output
```json
{}
```

### Resources or Replication Study article
Example Input
```json
{}
```

Example Output
```json
{}
```
