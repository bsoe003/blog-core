var view = require('../view');
var api = require('../api');
var message = require('../message');
var validate = require('../validate');

exports.form = function() {

    var model = {

        username: ko.observable(''),
        password: ko.observable(''),

        login: function(form) {

            validate.clear(form);

            var username = model.username();
            var password = model.password();

            if (username === '') {

                validate.error('username', 'Username is not entered.');
            }

            if (password === '') {

                validate.error('password', 'Password is not entered.');
            }

            if (validate.hasError(form)) {

                return false;
            }

            api.login(username, password).then(function(res) {

                if (res.status === 'success') {

                    sessionStorage.setItem('api-key', res.data.key);
                    sessionStorage.setItem('user-id', res.data.id);
                    sessionStorage.setItem('user-type', res.data.type);

                    route.go('posts');

                } else {

                    validate.formError(form, res.message);
                }

            }, message.error);
        }
    };

    return view.show('login', model);
};

// Clears the session tokens.

exports.logout = function() {

    sessionStorage.removeItem('api-key');
    sessionStorage.removeItem('user-id');
    sessionStorage.removeItem('user-type');

    route.go('login');
};
