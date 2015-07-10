(function() {
    'use strict';
    var container = $('#app'),
        token,
        Factory, Factories,
        LoginView, ListFactoriesView, EditFactoryView,
        Manager, app;


    token = (function() {
        var value = localStorage['auth'];
        return {
            get: function() {
                return value;
            },
            set: function(t) {
                localStorage['auth'] = value = t;
            }
        };
    }());


    $.ajaxSetup({
        beforeSend: function (xhr) {
            if (token.get()) {
                xhr.setRequestHeader("Authorization", token.get());
            }
        }
    });


    Factory = Backbone.Model.extend({
        defaults: {
            name: '',
            email: '',
            address: '',
            tags: []
        },

        geocode: function() {
            if (!this.get('address')) {
                return $.Deferred().reject();
            }

            var params = {
                q: this.get('address'),
                format: 'json'
            };

            return $.getJSON('http://nominatim.openstreetmap.org/search', params).then(function(results) {
                var res = _.first(results);
                if (!res) {
                    return null;
                }
                return _.pick(res, 'lat', 'lon');
            });
        }
    });


    Factories = Backbone.Collection.extend({
        model: Factory,
        url: '/api/1.0/protected/factories'
    });


    LoginView = Backbone.View.extend({
        className: "view-login",
        events: {
            "submit form": "submit",
        },

        render: function() {
            var html = nunjucks.render('view-login.html');
            this.$el.html(html);
        },

        submit: function(e) {
            e.preventDefault()
            var username = this.$el.find('#username').val(),
                password = this.$el.find('#password').val(),
                self = this,
                loading;

            loading = $.ajax({
                url: '/api/1.0/auth',
                type: 'GET',
                data: {
                    username: this.$el.find('#username').val(),
                    password: this.$el.find('#password').val()
                }
            });

            loading.then(function(data) {
                token.set(data.token);
                self.trigger('auth');
            }).fail(function() {
                alert('Authentication failed');
            });
        }
    });


    ListFactoriesView = Backbone.View.extend({
        className: "view-list-factories",
        events: {
            'click .delete': 'del'
        },

        initialize: function() {
            var repaint = _.throttle(this.render.bind(this), 500, {leading: false});

            this.factories = new Factories();
            this.factories.on('add', repaint);
            this.factories.on('destroy', repaint);
        },

        del: function(e) {
            e.preventDefault();
            var id = $(e.target).data('id'),
                factory = this.factories.get(id);

            if (!factory) {
                return;
            }

            if (confirm('Are you sure you want to delete ' + factory.get('name') + '?')) {
                factory.destroy();
            }
        },

        render: function() {
            var self = this;

            this.factories.fetch().then(function() {
                var html = nunjucks.render('view-list-factories.html', {
                    factories: self.factories
                });
                self.$el.html(html);
                self.drawMap(self.factories);
            });
        },

        drawMap: function(factories) {
            var map;

            map = new google.maps.Map(this.$el.find('.map').get(0), {
                zoom: 4,
                center: new google.maps.LatLng(39.833333, -98.583333) // Geo center of US
            });

            factories.map(function(factory) {
                return factory.geocode().then(function(res) {
                    if (!res) {
                        return;
                    }

                    var point = new google.maps.LatLng(res.lat, res.lon);

                    return new google.maps.Marker({
                        position: point,
                        map: map,
                        title: factory.get('name')
                    });
                });
            });
        }
    });


    EditFactoryView = Backbone.View.extend({
        className: "view-edit-factory",
        events: {
            'submit form': 'save'
        },

        initialize: function(options) {
            this.factoryID = options.factoryID;
        },

        render: function() {
            var self = this,
                factories;

            factories = new Factories();
            factories.fetch().then(function() {
                var html, title;

                if (self.factoryID) {
                    self.factory = factories.get(self.factoryID);
                    title = 'Edit Factory'
                } else {
                    self.factory = new Factory();
                    factories.add(self.factory);
                    title = 'Add New Factory'
                }

                html = nunjucks.render('view-edit-factory.html', {
                    title: title,
                    factory: self.factory
                });
                self.$el.html(html);
                self.$el.find('input[data-role=tagsinput]').tagsinput({});
            });
        },

        save: function(e) {
            var self = this;
            e.preventDefault();
            this.factory.set('name', this.$el.find('#name').val());
            this.factory.set('email', this.$el.find('#email').val());
            this.factory.set('address', this.$el.find('#address').val());
            this.factory.set('tags', this.$el.find('#tags').tagsinput('items'));
            this.factory.save().then(function() {
                self.trigger('saved');
            });
        }
    });


    Manager = Backbone.Router.extend({
        routes: {
            "factories/add": "editFactory",
            "factories/list": "listFactories",
            "factories/edit/:id": "editFactory",
            "login": "login",
            "*path": "login",
        },

        activate: function(view) {
            if (this.active) {
                this.active.remove();
            }

            this.active = view;
            container.empty().append(view.$el);
            view.render()
        },

        editFactory: function(id) {
            var view = new EditFactoryView({ factoryID: id }),
                self = this;
            view.on('saved', function() {
                self.navigate("factories/list", {trigger: true});
            });
            this.activate(view);
        },

        listFactories: function() {
            var view = new ListFactoriesView();
            this.activate(view);
        },

        login: function() {
            var view = new LoginView(),
                self = this;
            view.on('auth', function() {
                self.navigate("factories/list", {trigger: true});
            });
            this.activate(view);
        }
    });


    app = new Manager();
    Backbone.history.start();

    if (!token.get()) {
        app.navigate('login', {trigger: true});
    }
}());
