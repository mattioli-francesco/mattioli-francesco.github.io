---
layout: page
permalink: /teaching/
title: teaching
description: "Teaching political science and empirical methods at Bocconi University, with course slides, code, and datasets available to students."
nav: true
nav_order: 4
hide_title: true
hide_description: true
---

<div class="teaching">
  {% for role_block in site.data.teaching %}
    <!-- Role -->
    <div class="role">
      <div class="name role-name" style="font-size: 1.25rem; font-weight: 700;">{{ role_block.role }}</div>

      {% for uni in role_block.universities %}
        <!-- University -->
        <div class="university" style="margin-left: 1.25rem;">
          <div class="name">{{ uni.university }}</div>
          {% if uni.years %}
            <div class="years">{{ uni.years }}</div>
          {% endif %}
        </div>

        <!-- Courses -->
        <ul class="course-list" style="margin-left: 1.25rem;">
          {% for c in uni.courses %}
            <li class="course">
              <div class="title">
                {% if c.code %}
                  {% if c.url %}
                    <a href="{{ c.url }}">{{ c.code }}</a>{% if c.title %} – {{ c.title }}{% endif %}
                  {% else %}
                    {{ c.code }}{% if c.title %} – {{ c.title }}{% endif %}
                  {% endif %}
                {% else %}
                  {% if c.url %}
                    <a href="{{ c.url }}">{{ c.title }}</a>
                  {% else %}
                    {{ c.title }}
                  {% endif %}
                {% endif %}
              </div>

              {% if c.year %}
                <div class="year">{{ c.year }}</div>
              {% endif %}

              {% if c.modules %}
                <ul class="modules">
                  {% for m in c.modules %}
                    <li class="module-line">
                      <span class="module-name"><em>{{ m.name }}</em></span>

                      {% if m.slides %}
                        <a href="{{ m.slides | relative_url }}" class="btn btn-sm z-depth-0" role="button">Slides</a>
                      {% endif %}

                      {% if m.code %}
                        <a href="{{ m.code | relative_url }}" class="btn btn-sm z-depth-0" role="button">Code</a>
                      {% endif %}

                      {% if m.data_list %}
                        {% for d in m.data_list %}
                          <a href="{{ d.url | relative_url }}" class="btn btn-sm z-depth-0" role="button">
                            {{ d.name | default: 'Data' }}
                          </a>
                        {% endfor %}
                      {% elsif m.data %}
                        {% assign first_item = m.data | first %}
                        {% if first_item.url %}
                          {% for d in m.data %}
                            <a href="{{ d.url | relative_url }}" class="btn btn-sm z-depth-0" role="button">
                              {{ d.name | default: 'Data' }}
                            </a>
                          {% endfor %}
                        {% else %}
                          {% assign data_json = m.data | jsonify %}
                          {% if data_json | slice: 0,1 == '[' %}
                            {% for d in m.data %}
                              <a href="{{ d | relative_url }}" class="btn btn-sm z-depth-0" role="button">Data</a>
                            {% endfor %}
                          {% else %}
                            <a href="{{ m.data | relative_url }}" class="btn btn-sm z-depth-0" role="button">Data</a>
                          {% endif %}
                        {% endif %}
                      {% endif %}
                    </li>
                  {% endfor %}
                </ul>
              {% endif %}
            </li>
          {% endfor %}
        </ul>
      {% endfor %}
    </div>
  {% endfor %}
</div>
