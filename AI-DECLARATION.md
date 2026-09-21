---
version: "0.1.2"
level: pair
processes:
  design: assist
  implementation: pair
  documentation: assist
  testing: assist
  review: none
  deployment: none
---

This format is based on [AI-DECLARATION.md](https://ai-declaration.md/en/0.1.2).

## Notes

- First of all , which llm was used , it is - Local LLM is used , via [Ollama](https://ollama.com/) and paired with [OpenCode](https://opencode.ai/). No online LLM was ever used in project development.


### Expectations for contributors

If you use AI to help write a contribution, **please just declare it first**. PR which can be done easily with simple logic will be rejected as LLM puts a lot of overthinking , which was never necessary for specific problem PR trying to solve. 
