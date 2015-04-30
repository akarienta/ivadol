'use strict'

module.exports = (grunt) ->

   # paths config
   appConfig =
      app: 'app'
      dist: 'dist'

   # configuration
   grunt.initConfig

      config: appConfig

      # grunt clean
      clean:
         dev: '.tmp'
         dist: [
            '<%= config.dist %>'
            '.tmp'
         ]
         sass: '.tmp/styles'
         coffee: '.tmp/scripts'

      # auto insertion of scrips from bower_components
      wiredep:
         app:
            src: ['<%= config.app %>/index.html']
            ignorePath: /\.\.\//

      # grunt sass
      sass:
         compile:
            options:
               style: 'expanded'
            files: [
               expand: true
               cwd: '<%= config.app %>/styles'
               src: ['**/*.scss']
               dest: '.tmp/styles'
               ext: '.css'
            ]

      # auto annotation of AngularJS injection
      ngAnnotate:
         all:
            files: [
               expand: true
               cwd: '<%= config.app %>/scripts'
               src: '**/*.js'
               dest: '.tmp/scripts'
            ]

      # grunt connect
      connect:
         options:
            port: 9000
            hostname: 'localhost'
            livereload: true
         livereload:
            options:
               open: true
               middleware: (connect) ->
                  [
                     connect.static('.tmp')
                     connect().use(
                             '/bower_components',
                             connect.static('./bower_components')
                     )
                     connect.static(appConfig.app)
                  ]

      # grunt watch
      watch:
         bower:
            files: 'bower.json'
            tasks: 'wiredep'
         html:
            files: '<%= config.app %>/**/*.html'
         js:
            files: '<%= config.app %>/**/*.js'
            tasks: ['ngAnnotate']
         sass:
            files: '<%= sass.compile.files[0].src %>'
            tasks: ['clean:sass', 'sass:compile']
         livereload:
            options:
               livereload: '<%= connect.options.livereload %>'
            files: [
               '<%= config.app %>/{,*/}*.html'
               '.tmp/styles/{,*/}*.css'
               '.tmp/scripts/{,*/}*.js'
               '<%= config.app %>/images/{,*/}*.{png,jpg,jpeg,gif,svg}'
            ]

      # grunt copy
      copy:
         dist:
            files: [
               {
                  # pages
                  expand: true,
                  cwd: '<%= config.app %>',
                  src: ['**/*.html'],
                  dest: '<%= config.dist %>'
               }
               {
                  # images
                  expand: true,
                  cwd: '<%= config.app %>/images',
                  src: ['**/*.{png,jpg,jpeg,gif,svg}'],
                  dest: '<%= config.dist %>/img'
               }
            ]

      # preparation of CSS and JS minification
      useminPrepare:
         html: '<%= config.app %>/index.html'
         options:
            dest: '<%= config.dist %>'

      # CSS and JS minification
      usemin:
         html: '<%= config.dist %>/index.html'

      # HTML minification
      htmlmin:
         dist:
            options:
               removeComments: true
               collapseWhitespace: true
            files: [
               expand: true,
               cwd: '<%= config.dist %>',
               src: ['**/*.html'],
               dest: '<%= config.dist %>'
            ]

      # generates translation templates
      nggettext_extract:
         pot:
            files:
               '<%= config.app %>/po/template.pot': [
                  '<%= config.app %>/**/*.html'
                  '.tmp/scripts/**/*.js'
               ]

      # compiles translation files
      nggettext_compile:
         all:
            files:
               '<%= config.app %>/scripts/translations.js': [
                  '<%= config.app %>/po/*.po'
               ]

   require('load-grunt-tasks') grunt
   require('time-grunt') grunt

   grunt.registerTask 'serve', [
      'clean:dev'
      'wiredep'
      'sass'
      'ngAnnotate'
      'connect:livereload'
      'watch'
   ]

   grunt.registerTask 'build', [
      'clean:dist'
      'wiredep'
      'sass'
      'ngAnnotate'
      'copy:dist'
      'useminPrepare'
      'concat'
      'cssmin'
      'uglify'
      'usemin'
      'htmlmin'
   ]

   grunt.registerTask 'genpot', [
      'coffee'
      'nggettext_extract'
   ]

   grunt.registerTask 'translate', [
      'nggettext_compile'
   ]