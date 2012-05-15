// The recommended practice is not to include any JS code 
// in a manifest file - like this one. Instead, split JS code 
// in other .js files and require them as needed

//= require jquery 
//= require jquery_ujs 
//= require jquery-ui
//= require_directory ../../../vendor/assets/javascripts/popeye 
//= require ../../../vendor/assets/javascripts/media-viewer/documentViewer/libs/yepnope.1.5.3-min
//= require ../../../vendor/assets/javascripts/media-viewer/documentViewer/ttw-document-viewer.min
//= require_directory ./shared
//= require_directory ./core
//= require_directory ../../../vendor/assets/javascripts/happy 
