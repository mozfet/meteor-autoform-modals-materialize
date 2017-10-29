Package.describe({
    name: 'mozfet:autoform-modals-materialize',
    summary: "Create, update and delete collections with materialize modals",
    version: "2.0.11",
    git: "https://github.com/mozfet/meteor-autoform-modals-materialize",
});

Package.on_use(function(api) {
    api.versionsFrom('METEOR@1.4');

    api.use([
        'jquery',
        'templating',
        'less',
        'session',
        'coffeescript',
        'ui',
        'blaze-html-templates',
        'aldeed:autoform@6.0.0',
        'mozfet:autoform-materialize@2.0.10',
        'raix:handlebar-helpers@0.2.4',
        'mpowaga:string-template@0.1.0',
    ], 'client');

    api.use('ecmascript@0.7.2');

    api.imply([
        'aldeed:autoform@6.0.0',
        'mozfet:autoform-materialize@2.0.10',
    ]);

    api.add_files('lib/client/modals.html', 'client');
    api.add_files('lib/client/modals.coffee', 'client');
    api.add_files('lib/client/modals.less', 'client');
});
