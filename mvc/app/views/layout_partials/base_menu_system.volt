<aside id="navigation" class="page-side col-xs-12 col-sm-3 col-lg-2 hidden-xs">
    <div class="row testphalcon">
        <nav class="page-side-nav">
            <div id="mainmenu" class="panel" style="border:0px">
                <div class="panel list-group" style="border:0px">
                    {% for topMenuItem in menuSystem %}
                        {% if topMenuItem.Children|length >= 1 %}
                            <!-- 最外層 topMenuItem.Id = 最上層名稱 -->
                            <a href="#{{ topMenuItem.Id }}" class="list-group-item {% if topMenuItem.Selected %}  active-menu-title {% endif  %}" data-toggle="collapse" data-parent="#mainmenu">
                                <span class="{{ topMenuItem.CssClass }} __iconspacer"></span>{{ lang._(topMenuItem.VisibleName) }}
                            </a>
                            <!-- 第二層 subMenuItem.Id = 第二層名稱 -->
                            <div class="collapse  {% if topMenuItem.Selected %} active-menu in {% endif  %}" id="{{ topMenuItem.Id }}">
                                {% for subMenuItem in topMenuItem.Children %}
                                    <!-- 非url生成 -->
                                    {% if subMenuItem.Url == '' %}
                                    {# next level items, submenu is a container #}
                                        <!-- 第三層 -->
                                        <a href="#{{ topMenuItem.Id }}_{{ subMenuItem.Id }}" 
                                            class="menu-a-radius list-group-item 
                                            {% if subMenuItem.Selected %}  active-menu-title {% endif  %} 
                                            {% if subMenuItem.Id == 'DHCPv4' %} hide {% endif %} 
                                            {% if subMenuItem.Id == 'DHCPv6' %} hide {% endif %}
                                            "
                                            data-toggle="collapse" data-parent="#{{ topMenuItem.Id }}">
                                            <div style="display: table;width: 90%;">
                                                <div style="display: table-row">
                                                    <div style="display: table-cell">{{ lang._(subMenuItem.VisibleName) }}</div>
                                                    <div style="display: table-cell; text-align:right; vertical-align:middle;">
                                                        <span class="{{ subMenuItem.CssClass }}"></span>
                                                    </div>
                                                </div>
                                            </div>
                                        </a>
                                        <!-- 第四層 -->
                                        <div class="collapse {% if subMenuItem.Selected %} active-menu in {% endif  %}" id="{{ topMenuItem.Id }}_{{ subMenuItem.Id }}">
                                            {% for subsubMenuItem in subMenuItem.Children %} {% if subsubMenuItem.IsExternal == "Y" %}
                                            <a href="{{ subsubMenuItem.Url }}" target="_blank" rel="noopener noreferrer" class="font-8px menu-a-a list-group-item menu-level-3-item {% if subsubMenuItem.Selected %} active {% endif  %}">{{ lang._(subsubMenuItem.VisibleName) }}</a>
                                            {% elseif acl.isPageAccessible(session.get('Username'),subsubMenuItem.Url) %}
                                            <a href="{{ subsubMenuItem.Url }}" class="font-8px menu-a-a list-group-item menu-level-3-item {% if subsubMenuItem.Selected %} active {% endif  %}">{{ lang._(subsubMenuItem.VisibleName) }}</a>
                                            {% endif %} {% endfor %}
                                        </div>
                                    <!-- url生成 -->
                                    {% elseif subMenuItem.IsExternal == "Y" %}
                                    <!-- 設置隱藏條件{% if subMenuItem.Url == '/system_usermanager_passwordmg.php' %} hide {% endif  %} -->
                                        <a href="{{ subMenuItem.Url }}" target="_blank" rel="noopener noreferrer" 
                                            class="menu-a-radius list-group-item 
                                            {% if subMenuItem.Selected %} active {% endif  %} 
                                            {% if subMenuItem.Url == '/system_usermanager_passwordmg.php' %} hide {% endif  %}
                                            "
                                            aria-expanded="{% if subMenuItem.Selected %}true{%else%}false{% endif  %}">
                                            <div style="display: table;width: 90%;">
                                                <div style="display: table-row">
                                                    <div style="display: table-cell">{{ lang._(subMenuItem.VisibleName) }}</div>
                                                    <div style="display: table-cell; text-align:right; vertical-align:middle;">
                                                        <span class="{{ subMenuItem.CssClass }}"></span>
                                                    </div>
                                                </div>
                                            </div>
                                        </a>
                                    {% elseif acl.isPageAccessible(session.get('Username'),subMenuItem.Url) %}
                                        <a href="{{ subMenuItem.Url }}" 
                                            class="menu-a-radius list-group-item {% if subMenuItem.Selected %} active {% endif  %} {% if subMenuItem.Url == '/system_usermanager_passwordmg.php' %} hide {% endif  %}">
                                            <div style="display: table;width: 90%;">
                                                <div style="display: table-row">
                                                    <div style="display: table-cell">{{ lang._(subMenuItem.VisibleName) }}</div>
                                                    <div style="display: table-cell; text-align:right; vertical-align:middle;">
                                                        <span class="{{ subMenuItem.CssClass }}"></span>
                                                    </div>
                                                </div>
                                            </div>
                                        </a>
                                    {% endif %}
                                {% endfor %}
                            </div>
                        {% else %}
                            {# parent level link menu items that pivot #}
                            {% if topMenuItem.IsExternal == "Y" %}
                                <a href="{{ topMenuItem.Url }}" target="_blank" rel="noopener noreferrer" class="list-group-item {% if topMenuItem.Selected %}  active-menu-title {% endif  %}" data-parent="#mainmenu">
                                    <span class="{{ topMenuItem.CssClass }} __iconspacer"></span>{{ lang._(topMenuItem.VisibleName) }}
                                </a>
                            {% elseif acl.isPageAccessible(session.get('Username'),topMenuItem.Url) %}
                                <a href="{{ topMenuItem.Url }}" class="list-group-item {% if topMenuItem.Selected %}  active-menu-title {% endif  %}" data-parent="#mainmenu">
                                    <span class="{{ topMenuItem.CssClass }} __iconspacer"></span>{{ lang._(topMenuItem.VisibleName) }}
                                </a>
                            {% endif %}
                        {% endif %}
                    {% endfor %}
                </div>
            </div>
        </nav>
    </div>
</aside>
