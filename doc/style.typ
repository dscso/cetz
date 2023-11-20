#import "example.typ": example

#import "@preview/tidy:0.1.0"
#import "@preview/t4t:0.3.2": is

#let show-function(fn, style-args) = {
  [
    #heading(fn.name, level: style-args.first-heading-level + 1)
    #label(style-args.label-prefix + fn.name + "()")
  ]
  let description  = if is.sequence(fn.description) {
    fn.description.children
  } else {
    (fn.description,)
  }
  let parameter-index = description.position(e => {
    type(e) == content and e.func() == heading and e.body == [parameters]
  })
  
  if parameter-index != none {
    description.slice(0, parameter-index).join()
  } else {
    description.join()
  }

  block(breakable: style-args.break-param-descriptions, {
    heading("Parameters", level: style-args.first-heading-level + 2)
    (style-args.style.show-parameter-list)(fn, style-args.style.show-type)
  })

  for (name, info) in fn.args {
    let types = info.at("types", default: ())
    let description = info.at("description", default: "")
    if description == [] and style-args.omit-empty-param-descriptions { continue }
    (style-args.style.show-parameter-block)(
      name, types, description, 
      style-args,
      show-default: "default" in info, 
      default: info.at("default", default: none),
    )
  }

  if parameter-index != none {
    description.slice(parameter-index+1).join()
  }
}

#let show-parameter-block(name, types, content, show-default: true, default: none, ..a) = {
  if type(types) != array {
    types = (types,)
  }
  block(breakable: false, width: 100%, stack(
    dir: ltr,
    [/ #name: #types.map(tidy.styles.default.show-type).join(" or ") \ #content],
    if show-default { align(right, [Default: #raw(lang: "typc", repr(default))]) }
  ))
}


#let show-type = tidy.styles.default.show-type
#let show-outline = tidy.styles.default.show-outline
#let show-parameter-list = tidy.styles.default.show-parameter-list

#let style = (
  show-function: show-function,
  show-parameter-block: show-parameter-block,
  show-type: show-type,
  show-outline: show-outline,
  show-parameter-list: show-parameter-list
)

#let parse-show-module(path) = {
  tidy.show-module(
    tidy.parse-module(
      read(path),
      scope: (
        example: example,
        show-parameter-block: show-parameter-block
      )
    ),
    show-outline: false,
    sort-functions: none,
    style: style
  )
}