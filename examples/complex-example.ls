...
# missing is an array that contains missign document ids
b2 = new SignalBranch
unless empty missing
    b2s1 = b2.add!
    @log.debug "Missing clients: ", JSON.stringify missing
    count.missing-ids = missing
    err, res <~ @other-db.get-clients {some-options}
    new-clients = []
    b1 = new SignalBranch
    unless err or empty res
        b1s1 = b1.add!
        new-clients = []
        # generate new-client docs at this point
        # ...
        b3 = new SignalBranch
        err, res <~ @db.put new-clients
        unless err
            @log.success "New clients #{new-clients.length} synced into Scada"
            count.added = try new-clients.length
        else
            b3s1 = b3.add!
            @log.error "Can not put into Scada"
            ids = [..id for res when ..error is \conflict]
            failed-clients = filter (._id in ids), new-clients
            err, res <~ @db.get ids
            # assign appropriate properties from current to new documents
            err, res <~ @db.put res
            if err
                @log.error "Can not put failed transfers"
            else
                @log.success "Failed transfers are updated."
                count.added += (failed-clients?.length or 0)

            b3s1.go err
        err <~ b3.joined
        b1s1.go err
    err <~ b1.joined
    b2s1.go err
err <~ b2.joined
callback err, count
