# PDF-1 Content

## What is CI/CD?
November 7, 2024

**Building automated workflows for faster releases**

### What is CI/CD?

CI/CD stands for Continuous Integration and Continuous Deployment (or Continuous Delivery). It's a set of practices and tools designed to improve the software development process by automating builds, testing, and deployment, enabling you to ship code changes faster and reliably.

**Continuous integration (CI):** Automatically builds, tests, and integrates code changes within a shared repository

**Continuous delivery (CD):** automatically delivers code changes to production-ready environments for approval

**Continuous deployment (CD):** automatically deploys code changes to customers directly

CI/CD comprises of continuous integration and continuous delivery or continuous deployment. Put together, they form a "CI/CD pipeline"—a series of automated workflows that help DevOps teams cut down on manual tasks.

### Example of a CI/CD pipeline

### Continuous delivery vs. continuous deployment

When someone says CI/CD, the "CD" they're referring to is usually continuous delivery, not continuous deployment. What's the difference? In a CI/CD pipeline that uses continuous delivery, automation pauses when developers push to production. A human—your operations, security, or compliance team—still needs to manually sign off before final release, adding more delays. On the other hand, continuous deployment automates the entire release process. Code changes are deployed to customers as soon as they pass all the required tests.

Continuous deployment is the ultimate example of DevOps automation. That doesn't mean it's the only way to do CI/CD, or the "right" way. Since continuous deployment relies on rigorous testing tools and a mature testing culture, most software teams start with continuous delivery and integrate more automated testing over time.

### Why CI/CD?

The short answer: Speed. The State of DevOps report found organizations that have "mastered" CI/CD deploy 208 times more often and have a lead time that is 106 times faster than the rest. While faster development is the most well-known benefit of CI/CD, a continuous integration and continuous delivery pipeline enables much more.

**Development velocity:** Ongoing feedback allows developers to commit smaller changes more often, versus waiting for one release.

**Stability and reliability:** Automated, continuous testing ensures that codebases remain stable and release-ready at any time.

**Business growth:** Freed up from manual tasks, organizations can focus resources on innovation, customer satisfaction, and paying down technical debt.

### Building your CI/CD toolkit

> "The mindset we carry is that we always want to automate ourselves into a better job. We want to make sure that the task we're doing manually today becomes mostly automated."
> 
> Andrew Mulholland, Director of Engineering

Teams make CI/CD part of their development workflow with a combination of automated process, steps, and tools.

**Version control:** CI begins in shared repositories, where teams collaborate on code using version control systems (VCS) like Git. A VCS tracks code changes, simplifies reversions, and supports config as code for managing testing and infrastructure. Learn more about version control

**Builds:** CI build tools automatically package up files and components into release artifacts and run tests for quality, performance, and other requirements. After clearing required checks, CD tools send builds off to the operations team for further testing and staging.

**Reviews and approvals:** Treating code review as a best practice improves code quality, encourages collaboration, and helps even the most experienced developers make better commits. In a CI/CD workflow, teams review and approve code or leverage integrated development environments for pair programming.

**Environments:** CI/CD tests and deploys code in environments, from where developers build code to where operations teams make applications publicly available. Environments often have their own specific variables and protection rules to meet security and compliance requirements.

### Example CI/CD workflow

CI/CD doesn't have to be complicated, or mean adding a host of tools on top of your current workflow. At mabl, developers deploy to production about 80 times a week using only two CI/CD integrations: The mabl testing suite and GitHub Actions. Here's how it works. ✨

1. Developers open pull requests to trigger initial builds and unit tests
2. Approved commits are deployed to a preview environment
3. Custom-built GitHub Actions install the mabl CLI and run headless tests
4. GitHub Apps provide live check results within pull requests
5. Approved commits are merged to the main branch for additional tests or deployed to production

### What makes CI/CD successful

You'll find different tools and integrations everywhere you look, but effective CI/CD workflows all share the same markers of success.

**Automation:** CI/CD can be done manually—but that's not the goal. A good CI/CD workflow automates builds, testing, and deployment so you have more time for code, not more tasks to do.

**Transparency:** If a build fails, developers need to be able to quickly assess what went wrong and why. Logs, visual workflow builders, and deeply integrated tooling make it easier for developers to troubleshoot, understand complex workflows, and share their status with the larger team.

**Speed:** CI/CD contributes to your overall DevOps performance, particularly speed. DevOps experts gauge speed using two DORA metrics: Lead time for changes (how quickly commits are made to code in production) and deployment frequency (how often you commit code).

**Resilience:** When used with other approaches like test coverage, observability tooling, and feature flags, CI/CD makes software more resistant to errors. DORA measures this stability by tracking mean time to resolution (how quickly incidents are resolved) and change failure rate (the number of software rollbacks).

**Security:** Automation includes security. With DevSecOps gaining traction, a future-proof CI/CD pipeline has checks in place for code and permissions, and provides a virtual paper trail for auditing failures, security breaches, non-compliance events.

**Scalability:** CI/CD isn't just about automation; it's also about ensuring scalability. A robust CI/CD setup should effortlessly expand with your growing development team and project complexity. This means it can efficiently handle increased workloads as your software development efforts grow, maintaining productivity and efficiency.

### See What's Possible with CI/CD: Real Customer Stories

See how DevOps teams put continuous automation into practice.

**Blue Yonder:** Migrating from internal servers to cloud-based CI/CD.

**Plaid:** Improving deployment time and developer productivity.

**3M:** Breaking down silos with shared tooling and automation.

### What can you do with CI/CD?

Whether you're ready to dive in or still have questions, we've got you covered.

**Explore best practices:** Explore best practices

**Get a GitHub demo:** See how world-class CI/CD, automation, and security can support your workflow.

**Ask the experts:** Build a custom strategy for your business goals in a 1:1 session with GitHub product leaders.

**Compare DevOps solutions:** See how GitHub compares to other DevOps tools and platforms.

---

# PDF-2 Content

## What is DevOps automation?
July 29, 2024

DevOps automation is a modern approach to software development that uses tools and processes to automate tasks and streamline workflows. It brings together developers, IT operations, and security teams to help them collaborate effectively and deliver reliable software. With DevOps automation, organizations are able to handle repetitive tasks, optimize processes, and deploy applications to production faster.

DevOps automation takes two concepts—DevOps and automation—and uses them to complement the agile software development process. DevOps incorporates continuous integration, continuous delivery, and continuous deployment (CI/CD) to help developers and IT operations efficiently and effectively build, test, and provide feedback during the process of delivering software solutions. DevOps is important for helping organizations to:

- Minimize deployment delays
- Shorten production cycles
- Increase performance
- Reduce errors

Automation uses technology to perform repetitive or tedious DevOps tasks so that humans don't have to. Its purpose is to give those humans the ability to focus their time and effort on mission-critical activities. Automation is used in the design and development, deployment, and monitoring phases of the DevOps workflow.

DevOps automation optimizes the software development lifecycle (SDLC) and helps to achieve consistent configurations, improve the speed and quality of releases, and scale to meet changing needs.

There are DevOps tools for:

**Planning and collaboration:** manage project requirements, track progress, and communicate with stakeholders.

**Build:** automate software builds from source code to testing.

**CI/CD:** automate integration, code change testing, and deployment to production.

**Operations and continuous monitoring:** monitor application performance, troubleshoot issues, and manage infrastructure.

**Development, security, and operations (DevSecOps):** include security testing and compliance in the development process.

Adopting DevOps automation empowers teams to stop putting effort into repetitive and time-consuming tasks and instead focus on tasks that add business value. DevOps automation helps organizations to:

**Increase development speed and code quality.** Developers are able to streamline CI/CD, address issues earlier in the SDLC, and facilitate shorter feedback loops.

**Facilitate collaboration and agility.** Teams have more time to spend on innovating and are able to respond quickly and effectively to customer needs or to changes in the market.

**Reduce downtime and increase reliability.** Tools that aim to reduce risks and minimize user impact empower organizations to recover from incidents more quickly.

**Discover greater time and cost savings.** Automated tools reduce the risk of human error and help teams to focus on resolving problems instead of identifying them.

### How does DevOps automation work?

Automation supports DevOps by streamlining its lifecycle, which consists of planning, coding, building, testing, packaging, releasing, operating, and monitoring.

DevOps automation enables developers, IT operations, and security teams to collaborate throughout the DevOps lifecycle to define application and infrastructure requirements and to identify places for automation during the process of delivering software solutions.

For example, an automated software testing tool uses test scripts to validate that an application works as expected before releasing it to production. This type of tool is also capable of testing software beyond its normal operating limits and determining its robustness and error-handling when it encounters unexpected user interactions or invalid input.

DevOps automation is also used to proactively monitor applications after they go live. Performance issues are reported to DevOps teams based on pre-defined thresholds, which helps them to prioritize when and how to respond.

Besides testing and continuous monitoring, DevOps processes that can be automated include provisioning, CI/CD, deployment, and infrastructure management.

There's no single tool that does it all when it comes to DevOps automation; however, selecting specific tools does enable infrastructure customization. Tools that help with DevOps automation include:

**CI/CD tools** that automate the build, test, and release pipeline to help minimize human error, maximize code quality, and improve application security. These tools provide dashboard and reporting functions that work with version control and agile tools.

**Configuration management tools** that help to ensure that hardware and software perform as expected. A declarative configuration tool automates the process of achieving the desired state instead of having to write out the necessary steps.

**Containerization tools** that package applications with their code, runtime, system tools and libraries, and settings to help ensure that software works as expected, no matter the infrastructure.

**Orchestration tools** that automate the deployment, management, and scaling of containerized applications. Tools like these help IT teams to manage tasks and workflows.

**Package management tools** that simplify the installation, upgrading, configuration, and removal of software. They maintain a database of software dependencies and version information and help to ensure package integrity and authenticity.

**Web hosting tools** that provide a way for software developers to create an external website that tells people about the application being built. These tools can turn repositories into webpages that share project information, documentation, or videos—anything that would be helpful for potential customers.

### Best practices for DevOps automation

While automation goes a long way in reducing human error throughout the DevOps lifecycle, it may not be possible to automate every aspect. Best practices for DevOps automation include:

**Implementing infrastructure as code** to simplify the setup, configuration, and maintenance of IT resources and to enable scalability and agility. Infrastructure as code also provides an auditable change trail.

**Relying on CI/CD** to help test all changes and see if they break anything, deploy successful release candidates, and automatically send changes to production.

**Employing change management** and adhering to version and change control procedures; they encourage collaboration and reduce the chance of harmful changes to the code.

**Practicing continuous monitoring** of live applications for performance and stability. It minimizes service interruptions and provides valuable insight to the teams who troubleshoot, debug, and patch.

### Optimize DevOps processes with automation

There's no one-size-fits-all approach to DevOps automation. That's why GitHub offers a range of tools to help you streamline your DevOps pipeline and give your developers the tools to do their best work. Explore GitHub now to find the right services for your organization.

# PDF-3 Content

## A guide to DevOps tools and DevOps automation toolchains
May 23, 2022 // 14 min read

### What are DevOps tools?

As an umbrella term, DevOps tools include any number of applications that automate processes within the software development lifecycle (SDLC), improve organizational collaboration, and implement monitoring and alerts. Organizations will often invest in building out a "DevOps toolchain," or collection of tools to use in its DevOps practice, to address each stage of the SDLC.

A DevOps toolchain is a core tenant of any DevOps practice, helping organizations apply automation to the SDLC and improve their ability to deliver higher-quality software faster. It's also one of the more tangible aspects of DevOps.

Some organizations will invest in an "all-in-one" platform to build their DevOps toolchain. Others will integrate different best-of-breed solutions to create a toolchain. But critically, there is no one-size-fits-all approach to DevOps or building a DevOps toolchain.

In this guide, we'll explore how the best DevOps toolchains address each stage of the SDLC. This includes:

- Planning and collaboration tools
- Build tools
- Continuous integration tools
- Continuous deployment tools
- Operations and continuous monitoring tools
- Security and DevSecOps tools

### DevOps planning and collaboration tools

In large part, DevOps seeks to bring previously siloed teams together across all stages of the SDLC—and that starts at the planning stage. From chat applications to project management tools, there are a number of tools organizations can implement in their DevOps toolchains to better align and encourage collaboration in an organization during its planning stages.

DevOps planning and collaboration tools generally fall into two buckets:

**Product and roadmap planning:** Having a centralized place to plan, track, and manage work is a foundational capability for any modern development team—and DevOps organizations, too. The best tools help organizations build plans, sprints, and roadmaps while being able to assign and track work from the initial plans to the delivered end product. Need an example? Try looking at our own public product roadmap plans, which we build using projects on GitHub.

**Team communication:** Maintaining communication throughout the planning process is key to spurring collaboration—and having a preserved record of conversations that led to a given decision can be incredibly helpful. Tools such as GitHub Discussions, chat applications, and issue trackers that enable team conversations are key here. GitHub provides apps to help your team integrate with Slack or Microsoft Teams. The best tools will integrate with your project planning, too. That means you can turn a discussion into an executable piece of work, or turn an idea into a discussion if more conversation is needed before work can start.

### DevOps build tools

Once developers commit code changes to a central repository, the build stage begins—and that means using version control to create shared repositories, provisioning development environments, and integrating code, among other things. At this stage, organizations typically leverage the following DevOps tools:

**Version and source control:** A version control system is designed to automatically record file changes and preserve records of previous file versions, which enables code rollbacks, historical references, and multiple code branches allowing developers to collaboratively code and work in parallel.

Platforms such as GitHub offer version control and source control with features such as pull requests, which enable individual developers to get reviews on proposed code changes before they are integrated into the main code branch. The best version and source control platforms integrate with your broader DevOps toolchain, and enable product teams to collaborate across the SDLC.

**Pre-production development environments:** In a DevOps practice, developers need to leverage virtual environments that mirror production as closely as possible. These environments are identical to one another and easy to provision, so that all developers can quickly build and test code changes in consistent environments.

Organizations will often leverage containerization platforms and registries such as GitHub Packages to build standardized, pre-production environments for development teams. Ideally, these platforms should integrate into the source control solution so that when a team member commits new code, it triggers the automated provisioning of a pre-production environment.

**Cloud-based integrated developer environments (IDE):** Cloud-based IDEs offer comprehensive development environments that are pre-configured and can be quickly provisioned. These are an increasingly popular tool in DevSecOps (and development circles more broadly, for that matter) since they help standardize developer environments including security configurations across machines. And since they're centrally managed, cloud-based IDEs also keep code off an individual developer's computer, which can improve overall development security.

Tools such as GitHub Codespaces also feature deep integrations into core DevOps platforms. This can improve development speeds by cutting down the amount of time it takes to spin up a developer environment—and reducing the need to wait for running builds and tests locally.

**Infrastructure as code:** The rise in cloud infrastructure, or Infrastructure as a Service (IaaS), has made it simpler to quickly provision resources to meet real-time demand. It's also introduced a need among organizations to manage complex cloud-based infrastructure at scale—both to provision new resources as they're needed and to manage resource clusters for pre- and post-production environments.

Infrastructure as code (IaC) draws on DevOps best practices to provision and manage cloud infrastructure resources right from a version control system like GitHub via YAML files. These files specify a CI/CD workflow automation that is triggered by an event such as a pull request, code commit, or code merge. Once this event happens, the workflow automates the provisioning and management of cloud infrastructure resources.

Since IaC relies on a combination of YAML configuration files that are stored in a shared repository, it's critical to make sure your version control and CI/CD platform of choice integrate seamlessly. Tools such as GitHub Actions offer this type of integration, which make it easier to manage infrastructure right from your repository with CI/CD.

### DevOps continuous integration tools

Continuous integration (CI) is a mainstay of any DevOps practice and combines the cultural practice of frequent code commits with automation to integrate that code successfully and create builds.

To successfully adopt CI, DevOps organizations typically use tools and platforms that do three things:

**CI:** As a practice, CI often involves committing multiple code changes a day to a shared repository and using automation to integrate these changes, applying a series of automated tests to the merged codebase to ensure its stability, and preparing the codebase for deployment. This level of automation requires deep integration between a version control solution and the larger CI/CD platform, which enables DevOps organizations to build CI/CD pipelines that are triggered by a code commit.

When you're looking for a good CI solution, you'll want to make sure it easily integrates with your version control solution. This integration is key to making sure you can build an automated pipeline that starts as soon as your development teams commit code changes.

A good example of this level of integration comes with the GitHub platform, which features platform-native CI/CD via GitHub Actions and also features a number of pre-built integrations for third-party CI/CD services. You'll also want to make sure that whatever CI/CD platform you choose can automatically apply tests at all stages of the SDLC and includes native support for containerization platforms.

**Automated testing:** Automated testing tools are a core part of any DevOps toolchain. Most platforms will offer automated testing as a capability making it simple to incorporate automated tests into key parts of the pipeline—for instance, after a code change is merged to the main branch.

The goal is to have a comprehensive testing strategy with basic unit tests, integration tests, and acceptance tests that are applied at key points in the SDLC. The best testing tools integrate seamlessly with—or are part of—your CI/CD platform and offer built-in code coverage and testing visualization. You'll also want to look for testing platforms that enable matrix build testing capabilities, or allow you to simultaneously test builds across multiple operating systems and runtime versions.

It's also a good practice to ensure that your automated test solution of choice comes with monitoring and alerts that integrate with your chat application of choice. This means that if something breaks, you can quickly get a notification and work to fix whatever the underlying problem. Tools such as GitHub Actions, for instance, can be used to send alerts to chat applications once a test fails for quicker remediation.

**Packaging:** Once code changes clear all tests in a CI/CD pipeline, they are packaged into independent units of code and prepared for deployment. DevOps organizations will typically leverage a package manager like GitHub Packages to facilitate the delivery of software packages to a shared repository in preparation for a release.

Package managers help remove the need for manual installations and help bundle code dependencies within a given project. There are different package managers for different code libraries—but you should ideally look for a solution that integrates with your version control system and your CI/CD platform.

### DevOps continuous deployment tools

Continuous deployment builds upon CI/CD by removing the need for human intervention when releasing software. Instead, a continuous deployment practice applies automation to every stage of the SDLC. That means if a code change clears all automated tests, it is deployed to production.

DevOps organizations that adopt continuous deployment will typically use tools that fall into two categories:

**Automated deployment:** Automated deployments are a core part of continuous deployment and having a toolchain that supports automated deployment. These capabilities are typically present in most CI/CD platforms. However, there is no one-size-fits-all approach to building out a continuous deployment pipeline—and it won't work with every application or environment.

If you decide to invest in continuous deployment, look for platforms that readily support the development and management of multiple environments. Importantly, you'll want a solution that helps protect you from "server drift," or differences between development, pre-production, and production environments. You'll also want to consider a platform that supports blue-green deployments, which enables you to slowly migrate traffic from an old version of an application to a new release to ensure its stability in production.

At GitHub, we provide deployment dashboards and CI/CD visualization displays as part of our native CI/CD tool GitHub Actions—and we consider these core features for any continuous deployment toolchain. This is meant to give DevOps organizations full visibility into different code branches, automated test results, audit logs, and ongoing deployments as they happen.

**Configuration management:** Configuration management is a process where technology teams manage the different environmental configurations necessary in the core infrastructure and application systems across the life of the product. It's also something that is frequently paired with CI/CD and versioning control via automation.

Just as a CI/CD pipeline applies automation across the SDLC, configuration management tools automatically apply configuration changes in response to trigger-based events. These automated workflows are typically built in a CI/CD tool and stored as text files (like YAML) in a shared Git repository. These can be used to orchestrate and manage container clusters with platforms. They can also be used to manage infrastructure as code (IaC) practices.

GitHub repositories and issues make it easy for IT professionals to work with systems that produce text-based configuration files for both IaC and Configuration as Code (CaC).

### Continuous testing tools

In a DevOps practice, testing doesn't stop at CI/CD—it's an ongoing practice that extends throughout the SDLC. And more importantly, DevOps seeks to replace siloed QA teams with a continuous testing practice that leverages automation and holistic testing strategies across the SDLC.

Each DevOps organization will design its own continuous testing strategy in accordance with its needs. GitHub Actions provides workflow automation related to testing and supports a rich set of open source and commercial testing tools. Every continuous testing strategy will leverage a combination of the following test types across the SDLC:

**Unit testing:** Unit tests are a way of testing small units of code to verify that they are structured correctly with isolated components. They are also the easiest tests to build and the fastest to execute, making them a foundational test to automate in any continuous testing practice.

**Integration testing:** Once you commit code changes to a repository, integration tests ensure build stability and that the codebase continues to work successfully. These tests are used to identify defects that emerge when different application processes and code units are merged together. Integration tests are commonly automated to begin as soon as code changes are committed to a codebase and test the interplay of multiple parts of an application.

**End-to-end and regression testing:** Building on integration testing, end-to-end and regression tests are applied after a codebase is packaged and staged in a pre-production environment. These tests are used to check if any old defects, bugs, or issues are reintroduced by code changes. Regression testing is commonly used before and after deployments to ensure that an application works as expected and does not contain any previously identified issues.

**Production testing:** After an application is deployed, production-level tests monitor application health and stability—and identify any issues before they cause problems for end users. Importantly, these tests help organizations identify any potential problems in a production environment with live user traffic that can't be fully replicated in a pre-production environment.

### DevOps operations and continuous monitoring tools

A successful DevOps practice touches every stage of the SDLC—and that includes production-level software, too. This means companies need to invest in core operations and continuous monitoring tools to evaluate application and infrastructure performance. If done right, these tools can help continuously identify potential issues across the SDLC.

DevOps organizations will be best served by investing in tools that have the following capabilities:

**Application and infrastructure monitoring:** Application and infrastructure monitoring are core components of a successful continuous monitoring practice. The best tools offer 24/7 automated monitoring of the application and infrastructure health and give DevOps practitioners alerts when something goes wrong—and visibility into what the underlying problem might be.

Ideally, you'll want to monitor application health in pre-production and production environments to track any process issues or areas to improve overall performance. This is also true for your underlying infrastructure where monitoring can lead to insights on how to improve your infrastructure as code (IaC) and configuration management policies.

Try looking for a tool that integrates with your version control tool and chat applications so you can immediately send alerts to the right people, and create issues to outline the scope of work for a solution.

**Audit logs:** Auditing is a central part of an effective operations and continuous monitoring practice—and resolving any incidents if and when they happen. They give DevOps practitioners a record of what happened, where it happened, and when it happened and can be critical to build behavioral models that led to an issue and improve application and infrastructure health.

Look for DevOps tools that have live logs and auditing retention periods to equip your teams with the information they need to improve core services and application performance.

**Incident and change tracking:** The primary goal of DevOps is to help organizations ship higher-quality software faster through deep collaboration and automation. And that means tracking incidents and changes as they arise and sharing them with the right people is critical.

To build a successful DevOps toolchain, you'll want to incorporate tools that surface incidents and changes on your core DevOps platform and shared repositories. The more centralized you can keep all reports on incidents and changes, the better. The goal is to create a single source of truth that makes it easier to identify and fix issues.

**Continuous feedback:** A core tenant of DevOps, continuous feedback is a practice that focuses on tracking user behavior and customer feedback about your core products and building actionable data to inform future investments in new features and system updates. This can include NPS survey data about how users are navigating your product. It can also include tracking and modeling user behavior in the product itself.

To build a continuous feedback practice, you'll want to identify core areas in your product and even outside it in places like social media and reviews where you can identify unexpected user behaviors and customer pain points. Look for tools that enable you to model and analyze user behaviors. You also might consider social listening tools, which you can use to track historical patterns on social media and review sites.

### Security and DevSecOps tools

As DevOps has evolved as practice, it has underscored the need to move past more traditional approaches to security which was often siloed from the core SDLC. To ensure you're shipping high-quality code, making security a core part of the DevOps practice is important. This practice is commonly called DevSecOps, which seeks to integrate security into every stage of the SDLC and make it a core part of CI/CD pipelines.

Companies that invest in DevOps often find the need to invest in also building a DevSecOps practice to ensure software security. This typically involves several tools that help organizations model potential threats and apply automated security testing at key stages of the SDLC. While organizations often try to grab individual tools to create a solution, integrated products like GitHub Advanced Security, can reduce the friction of bringing DevSecOps to your teams. By complementing their DevOps toolchain with DevSecOps tools, companies will often look for the following solutions:

**Threat modeling:** Here's a truism: It's a lot easier to find security vulnerabilities and potential weak points when you're developing software instead of after you've released it. Threat modeling is a practice that DevSecOps practitioners will engage in from the early planning stages of the SDLC to anticipate any issues and develop plans to solve them.

DevSecOps organizations today will also invest in threat modeling tools that leverage automation and monitoring to proactively identify threats and mitigation efforts. The best tools survey application and infrastructure threats, and will automatically track changes in the underlying codebase and infrastructure architecture.

Look for solutions that can integrate with your core DevOps toolchain to provide updates to relevant people on your team and show risk evaluation scores throughout the SDLC.

**Security dashboards:** Having a single view of your security profile including potential risks, testing coverage, alerts, and more is critical for any DevSecOps practice. Security dashboards are often used to collate and break down all relevant security information and provide a quick way to triage issues and assign tasks. At GitHub, we include a security overview page with GitHub Advanced Security to help showcase risk categories across projects and repositories and alert details, too. Ideally, you should look for tools that integrate with your wider DevSecOps security toolchain and offer a single view of your security profile.

**Static application security testing (SAST):** SAST tools are used to evaluate code before it is run to identify any potential security risks or vulnerabilities. Importantly, these tools do not need a running system to execute but can be performed on a static codebase.

The best tools will integrate directly into a shared repository and search out any security vulnerabilities, conduct dependency reviews, scan for any confidential password or secrets, and identify coding errors before they make it into production. These tools will also make it simple to find, triage, and prioritize fixes for any problems in your codebase.

You'll ideally want to look for a solution that integrates with your repository and can be automated to build out issues based on analysis. At GitHub, for instance, we have a SAST tool called Dependabot that analyzes all dependencies for any known security vulnerabilities—and it's directly integrated into every repository on the platform.

**Dynamic application security testing (DAST):** DAST is used to imitate malicious attacks on an application to find any potential vulnerabilities that might risk its real-world security. DAST tools typically analyze applications in pre-production environments to help DevSecOps practitioners identify any possible security flaws before they make it into production. These flaws typically include underlying issues attackers can exploit to run SQL injection attacks and cross-site scripting (XSS) attacks, among other things.

The best DAST tools will integrate with your CI/CD platform of choice so you can automate their deployment within the wider SDLC.

**Interactive application security testing (IAST):** IAST solutions are used to identify and profile risks and vulnerabilities in running applications—most often earlier in the SDLC before a release is made. These solutions leverage software instrumentation to monitor and collect information in pre-production environments through manual and automated tests. The best IAST solutions will include software composition analysis (SCA) tools to identify any open source component vulnerabilities.

**Container image scanning:** Due to their lightweight architectures, containers have made it simpler for DevOps organizations to build, test, deploy, and update applications in a fast and flexible manner. But large-scale container environments also introduce security risks due to the number of surface areas and potential for vulnerabilities. To mitigate against any risks, DevSecOps practitioners will leverage container scanning tools to identify issues in the container registry, scan container clusters at runtime, and prevent vulnerabilities from making it into production. Look for tools that can be integrated into your CI/CD pipeline and automated to run at specific points in your SDLC before a deployment—including the build, integration, and packaging stages.

### Unify your DevOps tools and processes on GitHub

As the largest and most advanced development platform in the world, GitHub helps millions of developers and companies collaborate, build, and deliver, faster. And with thousands of DevOps integrations, you can build with the tools you know from day one—or discover new ones.

See all DevOps integrations in GitHub Marketplace

> "Senior SCM Engineer Todd O'Connor at Adobe"

**PLAN**

Coordinate, manage, and update your work in one place with GitHub issues, discussions, and project boards. Then stay organized and on track by integrating the planning and project management tools you already use.

Explore project management tools

**CODE**

Collaborate, create, store code, and accelerate development with GitHub and Codespaces. Add in code quality integrations to automate code reviews for style, quality, security, and test‐coverage checks when you need them.

Explore code quality tools

**BUILD**

Ship faster with automated continuous integration powered by GitHub Actions and Packages. Trigger workflows based on GitHub events and publish your packages wherever you like, all with native tooling commands.

Explore mobile CI, container CI, or all CI tools

**TEST**

Stop bugs from getting to production by adding testing to your Actions workflows—including testing integrations from our partners and community.

Explore testing tools

**DEPLOY**

Automate continuous delivery with Actions or trigger deployment integrations from common CI/CD providers and major public clouds with GitHub any event.

Explore deployment tools

**MANAGE**

Connect your code to the management, logging, alerting, and monitoring tools your team uses in production. Easily measure impact, analyze performance, and monitor the impact of your code on your systems and users.

Explore analytics, alerting, logging and monitoring tools

**SECURE** Know your code stays secure at every step with CodeQL, Dependabot, and the security tools you use today.

Explore security and dependency management tools

Compare DevOps Solutions >

### Wondering how GitHub can help your business?

DevOps

Tell us more about your needs

Last name *
First name *
Work Email *
Phone
+1
Company *
What can we help you with?
Country *
Last name
First name
you@company.com
󾓦 US
Acme, Inc
Tell us how we can help. For support questions, head to github.com/contact

United States of America (the)

Yes please, I'd like GitHub and affiliates to use my information for personalized communications, targeted advertising and campaign effectiveness. See the GitHub Privacy Statement for more details.

Contact GitHub

**Product**
Features
Security
Team
Enterprise
Customer stories
The ReadME Project

**Pricing**

**Support**
Docs
Community Forum
Professional Services
GitHub Skills
Status
Contact GitHub

**Resources**
Roadmap
Compare GitHub

**Platform**
Developer API
Partners
Atom
Electron
GitHub Desktop

**Company**
About
Blog
Careers
Press
Inclusion
Social Impact
Shop

Terms Privacy Sitemap What is Git? Manage cookies Do not share my personal information

GitHub Inc. © 2025

English