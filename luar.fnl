(local fennel (require :fennel))
(local luar (require :luarmodule))

(set _G.kak luar.kak)
(set _G.addpackagepath luar.addpackagepath)

(let [chunk (luar.parseargs)]
    (fennel.eval chunk {:env _G :filename "luar"}))
