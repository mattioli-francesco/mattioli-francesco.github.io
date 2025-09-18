---
layout: default
permalink: /policy_public/
title: policy and public
description:
nav: true
nav_order: 3
hide_title: true # <- hide the H1 inside the page
hide_description: true # <- optional: hide the description too
---

<div class="publications">

  <h2 class="section-title">Policy Reports and Technical Notes</h2>
  <div class="bib policy_tech">
    {% bibliography --file policy_tech --template bib-policy_tech --group_by none %}
  </div>

  <h2 class="section-title">Outreach</h2>
  <div class="bib outreach">
    {% bibliography --file outreach --template bib-outreach --group_by none %}
  </div>

</div>
