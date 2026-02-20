
<!-- PROJECT LOGO -->


<br />
<div align="center">
	<a href="https://github.com/Gopmyc/Nexum">
		<img src="nexum_logo.jpg" alt="Logo" width="80" height="80">
	</a>


<h3 align="center">Nexum</h3>


<p align="center">
	A modular distributed runtime for building synchronized real-time applications.
	Instead of coding a monolithic program loop, Nexum lets you compose isolated behaviors orchestrated by a unified execution kernel.
	Designed for experimentation, multiplayer simulations, and scalable interactive systems.
	<br />
	<br />
	<a href="https://gopmyc.github.io/Nexum/"><strong>Explore the docs »</strong></a>
	<br />
	<br />
	<a href="https://github.com/Gopmyc/Nexum">View Repository</a>
	·
	<a href="https://github.com/Gopmyc/Nexum/issues/new?labels=bug">Report Bug</a>
	·
	<a href="https://github.com/Gopmyc/Nexum/issues/new?labels=enhancement">Request Feature</a>
</p>
</div>



⸻


<!-- TABLE OF CONTENTS -->


<details>
  <summary>Table of Contents</summary>
  <ol>
	<li><a href="#about-the-project">About The Project</a></li>
	<li><a href="#built-with">Built With</a></li>
	<li>
	  <a href="#getting-started">Getting Started</a>
	  <ul>
		<li><a href="#prerequisites">Prerequisites</a></li>
		<li><a href="#installation">Installation</a></li>
	  </ul>
	</li>
	<li><a href="#usage">Usage</a></li>
	<li><a href="#roadmap">Roadmap</a></li>
	<li><a href="#contributing">Contributing</a></li>
	<li><a href="#license">License</a></li>
	<li><a href="#contact">Contact</a></li>
  </ol>
</details>



⸻

About The Project

Nexum is a distributed execution runtime designed to orchestrate real-time applications through modular behaviors rather than imperative program flow.

Instead of writing a single main loop, you declare:
	•	execution environments
	•	behavior modules
	•	load order
	•	runtime instances

Nexum assembles and runs the system automatically.

The runtime operates in two coordinated roles:

SERVER → authoritative simulation
CLIENT → visualization and interaction

The same project runs in both contexts, enabling synchronized systems without duplicating architecture.

Key Features
	•	🧩 Modular behavior instancing
	•	🌐 Built-in client/server runtime model
	•	🔒 Isolated execution environments (sandboxed modules)
	•	⚙️ Configuration-driven architecture
	•	🔄 Deterministic lifecycle orchestration
	•	🧠 Runtime composition instead of imperative flow

<p align="right"><a href="#readme-top">🔝</a></p>



⸻

Built With
	•	

	•	

<p align="right"><a href="#readme-top">🔝</a></p>



⸻

Getting Started

Prerequisites

Install the LÖVR engine:

https://lovr.org/

⸻

Installation
	1.	Clone the repository

git clone https://github.com/Gopmyc/Nexum.git
cd Nexum


⸻

Usage

Run Nexum in server mode:

lovr . SERVER

Run Nexum in client mode:

lovr . CLIENT

Both sides share the same project and automatically load role-specific systems.

<p align="right"><a href="#readme-top">🔝</a></p>



⸻

Roadmap
	•	Runtime loader
	•	Module isolation system
	•	Distributed execution model
	•	Instanced lifecycle management
	•	Network state replication layer
	•	Hot-reload modules
	•	Persistent world support
	•	Tooling & debugging utilities
	•	Visual inspector

Have an idea? Open an issue.

<p align="right"><a href="#readme-top">🔝</a></p>



⸻

Contributing

Contributions are welcome — Nexum is architecture-driven and benefits from experimentation.

Steps:
	1.	Fork the repo
	2.	Create a branch (git checkout -b feature/MyFeature)
	3.	Commit (git commit -m 'Add MyFeature')
	4.	Push (git push origin feature/MyFeature)
	5.	Open a Pull Request

<p align="right"><a href="#readme-top">🔝</a></p>



⸻

License

Distributed under the MIT License.
See LICENSE￼ for details.

<p align="right"><a href="#readme-top">🔝</a></p>



⸻

Contact

Gopmyc
📧 gopmyc.pro@gmail.com
🔗 https://github.com/Gopmyc/Nexum

<p align="right"><a href="#readme-top">🔝</a></p>



⸻


<!-- MARKDOWN LINKS & IMAGES -->
