var playerSeller = null
var tempinfo = null

window.addEventListener('message', function(event) {
    var item = event.data;
   switch (item.action) {
       case "init":
            playerSeller = true
           open(item.data);
           break;
         case "buyer":
            playerSeller = false
            open(item.data);
            break;
       case "close":
           close();
           break;
   }
   $('.accept').click(function() {
        if(playerSeller) {
            $.post('https://hn-contract-beta/sendBuyer', JSON.stringify(tempinfo), ()=>{
                close();
            })
        } else {
            $.post('https://hn-contract-beta/accept', JSON.stringify(tempinfo))
            close();
        }
    })

    $('.cancel').click(close)

})

close = ()=> {
    $.post('https://hn-contract-beta/close', JSON.stringify({}))
    $('.container').hide();
    document.getElementById('vehicle-plate-input').removeEventListener('change', handlerChange); // kill eventlistener
    document.getElementById('vehicle-price-input').removeEventListener('change', handlerChange); // kill eventlistener
    document.getElementById('buyer-identifier-input').removeEventListener('change', handlerChange);
    tempinfo = null
    $('.accept').off('click');
    $('.cancel').off('click');
}

handlerChange = ()=> {
}


open = (d)=> {
    tempinfo = {
        seller: d.seller,
        buyer: d.buyer,
        vehicle: d.vehicle
    }

    document.getElementById('seller-name').innerHTML = d.seller.name;
    document.getElementById('seller-identifier').innerHTML = d.seller.citizenid;
    document.getElementById('buyer-name').innerHTML = d.buyer.name;
    document.getElementById('buyer-identifier').innerHTML = d.buyer.citizenid;
    document.getElementById('buyer-identifier-input').value = d.buyer.id;
    document.getElementById('vehicle-name').innerHTML = d.vehicle.model;
    document.getElementById('vehicle-plate-input').value = d.vehicle.plate;
    if (d.vehicle.price) {
        document.getElementById('vehicle-price-input').value = d.vehicle.price;
    }
    document.getElementById('vehicle-price-input').readOnly = !playerSeller;
    document.getElementById('vehicle-plate-input').readOnly //= !playerSeller;
    document.getElementById('buyer-identifier-input').readOnly = !playerSeller;
    document.getElementById('vehicle-price-input').addEventListener('change', function() {
        tempinfo.vehicle.price = this.value
    })
    document.getElementById('vehicle-plate-input').addEventListener('change', function() {
        tempinfo.vehicle.plate = this.value
    })
    
    document.getElementById('buyer-identifier-input').addEventListener('change', function() {
        $.post('https://hn-contract-beta/identifier', JSON.stringify({
            id: this.value
        }), (info) => {
            if (!info) return
            document.getElementById('buyer-name').innerHTML = info.name;
            document.getElementById('buyer-identifier').innerHTML = info.citizenid;
            tempinfo.buyer = {
                id: this.id,
                name: info.name,
                citizenid: info.citizenid
            }
        })

    })
    
    $('.container').show();    
}
// on click





