#set par(justify: true)
#set heading(numbering: "1.")
#set page(paper: "us-letter")

#let content_lr(left_content: content, right_content: content) = {
  set par(justify: false)
  set text(hyphenate: false)
  grid(
    columns: (auto, 1fr),
    align: (left, right),
    column-gutter: 16pt,
    left_content,
    right_content
  )
}

#text(weight: "bold", size: 24pt, "Data Documentation")

#let master = csv("master_metadata.csv", row-type: dictionary)

#for data_table in master {
  content_lr(
    left_content: heading(level: 1, data_table.name),
    right_content: raw(
      "data/" + data_table.directory + "/"
    )
  )
  show heading: it => [#v(0pt) #it.body]

  [
    === Sources
    #for sourcelink in data_table.url.split(",\r\n") {
      [- #link(sourcelink)]
    }

    === Description
    #data_table.description

    === Method
    #eval(mode: "code", "[" + data_table.method + "]")
  ]

  let subdir = csv("clean/" + data_table.directory + "_metadata.csv", row-type: dictionary)

  for doc in subdir {
    v(16pt)
    content_lr(
      left_content: heading(level: 2, doc.name),
      right_content: raw(
        "data/" + data_table.directory + "/" + doc.filename + ".csv"
      )
    )

    [
      === Description
      #doc.description
    ]

    let doc_file = csv("clean/" + data_table.directory + "/" + doc.filename + "_metadata.csv", row-type: dictionary)

    for col in doc_file {
      content_lr(
        left_content: text(
          weight: "bold",
          col.name
        ),
        right_content: [
          #if col.required == "TRUE" {
            highlight(
              extent: 8pt,
              radius: 4pt,
              fill: green.transparentize(75%)
            )[Required]
            h(20pt)
          }
          #highlight(
            extent: 8pt,
            radius: 4pt,
            fill: blue.transparentize(75%)
          )[#col.dtype]
          #h(20pt)
          #highlight(
            extent: 8pt,
            radius: 4pt,
            fill: red.transparentize(75%)
          )[column name: #col.column_name]
        ]
      )
      v(-8pt)
      eval(mode: "markup", col.description)
    }
  }
}