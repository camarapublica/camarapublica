#= require jquery
#= require jquery_ujs
#= require twitter/bootstrap
#= require_tree .

$ ->
  $logo = $('h2#logo a')
  $logo.on 'mouseover', (e) ->
    $logo.text('#cámarapública')
  $logo.on 'mouseleave', (e) ->
    $logo.text('#camarapublica')