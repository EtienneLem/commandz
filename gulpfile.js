var gulp = require('gulp');
var del = require('del');
var connect = require('gulp-connect');
var webpack = require('gulp-webpack');
var webpackConfig = require('./webpack.config.js');

var port = process.env.PORT || 8080;
var reloadPort = process.env.RELOAD_PORT || 35729;

var webpackFor = function(target) {
  del([target])

  configs = webpackConfig[target]
  if (!Array.isArray(configs)) { configs = [configs] }
  const streams = []

  for (var i = 0; i < configs.length; i++) {
    config = configs[i]

    streams.push(
      webpack(config)
        .pipe(gulp.dest(target))
    )
  }

  return streams
}

gulp.task('build', function () {
  return Promise.all(webpackFor('build'))
});

gulp.task('dist', function() {
  return Promise.all(webpackFor('dist'))
})

gulp.task('serve', function () {
  return connect.server({
    port: port,
    livereload: {
      port: reloadPort
    }
  });
});

gulp.task('reload-js', function () {
  return gulp.src('./build/*.js')
    .pipe(connect.reload());
});

gulp.task('watch', function () {
  gulp.watch(['./build/*.js'], gulp.task('reload-js'));
});

gulp.task('default', gulp.parallel('build', 'serve', 'watch'));
