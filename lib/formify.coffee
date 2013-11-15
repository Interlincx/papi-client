
module.exports = (attr_settings, input_settings) ->
  #console.log 'render form starts', input_settings
  if typeof input_settings.type == 'undefined'
    return false

  next_to = false
  if input_settings.client_editable == false
    $input = $('<input/>')
    $input.attr('type', 'hidden')
    $input.attr('data-input-type', 'hidden')
    return $input

  $label = $('<label/>')
  $label.html input_settings.title
  if input_settings.type == 'text'
    $input = $('<textarea/>')
    $input.attr('data-input-type', 'textarea')

    rows = 8
    cols = 40
    if typeof input_settings.rows != 'undefined'
      rows = input_settings.rows
      cols = input_settings.cols
    $input.attr('rows', rows)
    $input.attr('cols', cols)
  else if typeof input_settings.options != 'undefined'
    $input = $('<select/>')
    $input.attr('type', 'text')
    $input.attr('data-input-type', 'select')
    $input.attr('value', input_settings.value)
    for option, values of input_settings.options
      $option = $('<option/>')
      $option.append values
      $option.attr('value', option)
      $input.append $option

    $input.val(input_settings.value)
  else
    $input = $('<input/>')

    if input_settings.type is 'boolean'
      $label.addClass 'checkbox'
      $input.attr('type', 'checkbox')
      $input.attr('data-input-type', 'checkbox')
  
      if input_settings.value is '1'
        value = 'checked'
        $input.attr('checked', value)
      next_to = true
    else
      $input.attr('type', 'text')
      $input.attr('data-input-type', 'text')

  
  if typeof input_settings != "undefined" && typeof input_settings.tooltip != "undefined"
    $label.popover
      html: true
      trigger: 'hover'
      placement: 'bottom'
      content: ->
        input_settings.tooltip

  $input.addClass input_settings.class_name
  $input.attr('value', input_settings.value)
  for handle, value of attr_settings
    $input.attr(handle.replace(/_/g, '-'), value)

  $final_input = $("<div/>")
  if next_to
    $label.append $input
    $final_input.append $label
  else
    $final_input.append $label, $input

  return $final_input[0]


