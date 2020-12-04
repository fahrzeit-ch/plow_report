cspNonce = null
window.addEventListener 'load', ->
  cspNonce = document.querySelector("meta[name='csp-nonce']").getAttribute('content')

Turbolinks.Renderer.prototype.createScriptElement = (element) ->
  if element.getAttribute("data-turbolinks-eval") is "false"
    element
  else
    createdScriptElement = document.createElement("script")
    createdScriptElement.textContent = element.textContent
    createdScriptElement.async = false

    # Inline `copyElementAttributes`. Set old nonce
    for {name, value} in element.attributes
      if name is 'nonce'
        createdScriptElement.setAttribute(name, cspNonce)
      else
        createdScriptElement.setAttribute(name, value)

    createdScriptElement