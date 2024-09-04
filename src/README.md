# Session demos

This folder contains the step-by-step instructions to run the demos presented in the session. All the demos can be executed from the Azure AI Studio GUI, and the instructions are provided in the markdown files.

There's 4 demos:

- **Demo 1 - Get Started with Azure AI Studio**: this demo is an introduction to Azure AI Studio, where you will learn how to navigate the platform and explore the main features.
- **Demo 2 - Prompt Engineering Techniques in the Azure AI Studio Playground**: this demo is intended to present some basic and advanced prompt engineering techniques in the *Playground* of Azure AI Studio.
- **Demo 3 - Add your own data with Prompty**: this demo is intended to showcase how to build your first LLM-based solution and connect it to your business data, leveraging *Retrieval Augmented Generation*(RAG).
- **Demo 4 - Evaluate your prototype with Prompt Flow**: once your first flow is ready and connected to your data, go through this demo to evaluate the performance of your solution.

## Folder structure

This folder contains the following files and folders:

- `README.md`: this file.
- `set_up.md`: step-by-step instructions to set up the development environment for the demos using either the Azure Portal or the Azure CLI.
- `set_up.sh`: bash script to automatize Azure resources provisioning
- `.env.sample`: sample of the environment config file used to execute the app flow for demo 3 
- `demo1-get-started.md`: step-by-step instructions to run the demo 1.
- `demo2-prompt-engineering.md`: step-by-step instructions to run the demo 2.
- `demo3-add-your-own-data.md`: step-by-step instructions to run the demo 3.
- `demo4-evaluate-your-prototype.md`: step-by-step instructions to run the demo 4.
- `media`: folder containing images used in the markdown files.
- `data`: folder containing the sample datasets used in demos 3 and 4.
- `web_designer_app`: folder containing the source code files for demo 3 and 4. 

## Scenario

All the demos are based on the following scenario.
You are a developer at **Contoso Outdoor Company**, a leading *e-commerce company that sells outdoor gear and equipment*. Your team is working on a new website design and you have been tasked with generating text content, and code snippets for the website. You have heard about the power of generative AI models and want to explore how you can leverage them to generate content for the website.
