---
layout: default
permalink: /research/
title: research
description:
nav: true
nav_order: 2
hide_title: true # <- hide the H1 inside the page
hide_description: true # <- optional: hide the description too
redirect_from:
  - /publications/
---

<!-- _pages/publications.md -->

<!-- Bibsearch Feature -->

<div class="publications">

  <h2 class="section-title">Publications</h2>
  {% bibliography --file publications --template bib-publications %}

  <h2 class="section-title">Working Papers</h2>
  <div class="bib wp">
    {% bibliography --file working_papers --template bib-working_papers --group_by none %}
  </div>

  <h2 class="section-title">Works in Progress</h2>
  <div class="bib wip">
    {% bibliography --file work_in_progress --template bib-work_in_progress --group_by none %}
  </div>

</div>
