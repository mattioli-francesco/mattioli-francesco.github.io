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
  {% for uni in site.data.teaching %}
    <!-- University -->
    <div class="university">
      <div class="name">{{ uni.university }}</div>
      {% if uni.years %}
        <div class="years">{{ uni.years }}</div>
      {% endif %}
    </div>

    <!-- Roles -->
    {% for block in uni.roles %}
      <div class="role">
        <div class="role-name">{{ block.role }}</div>

        <!-- Courses -->
        <ul class="course-list">
          {% for c in block.courses %}
            <li class="course">
              <div class="title">
                {% assign raw  = c.title | strip %}
                {% assign code = raw | split: ' ' | first %}
                {% assign name = raw | remove_first: code | strip %}
                {% assign name = name | remove_first: '–' | remove_first: '—' | remove_first: '-' | strip %}

                {% if c.url %}
                  <a href="{{ c.url }}">{{ code }}</a>{% if name != '' %} – {{ name }}{% endif %}
                {% else %}
                  {{ code }}{% if name != '' %} – {{ name }}{% endif %}
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
      </div>
    {% endfor %}

{% endfor %}

</div>
