(local fennel (require :fennel))
(local luar (require :luarmodule))

(set _G.kak luar.kak)
(set _G.args luar.args)
(set _G.addpackagepath luar.addpackagepath)

(fn eval [chunk]
  (fennel.eval chunk {:env _G :filename "fennel"}))

(fn abort [_ chunk err]
  (let [message "error while executing fennel block:\n\nfennel %%(%s)\n\n%s\n"]
    (luar.debug (message:format chunk err))
    (luar.kak.fail "'fennel' check *debug* buffer")
    (os.exit 1)))

(luar.execute eval abort)
