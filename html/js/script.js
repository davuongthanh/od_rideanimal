window.addEventListener('message', function (event) {
    var data = event.data;
    
    if (data != undefined && data.display == true) {

        $('.animal_list').append(`
            <div class="animal">
                <img id="animal_avata" src="img/`+data.name+`.png"><br>
                <span id="animal_name">`+data.label+`</span><br>
                <span id="animal_price">Giá : <span style="color:#7FFF00;">`+data.price+`$</span></span><br>
                <input id="animal_buy" type="image" src="img/button/buy.png" onclick="animal_buy('`+data.name+`','`+data.label+`','`+data.price+`')" onmouseover="this.src='img/button/buy_hover.png'" onmouseout="this.src='img/button/buy.png'">
            </div>
        `);

        $('.container').show();
    }
});

function animal_buy(name,label,price) {
    $('.popup').fadeIn(200);
	$('.animal_list').empty();
	$('.container').fadeOut(100);

	$('#popupYes').on('click', function (e){
		$.post('http://od_rideanimal/animal_buy', JSON.stringify({ name: name, label: label, price: price}));
		name = '';
		label = '';
		price = 0;
		$('.popup').fadeOut(100);
		$.post('http://od_rideanimal/NUIFocusOff');
		return;
	});
	
	$('#popupNo').on('click', function (e) {
		name = '';
		label = '';
		price = 0;
		$('.popup').fadeOut(200);
		$.post('http://od_rideanimal/NUIFocusOff');
		return;
	});    

}

document.addEventListener('DOMContentLoaded', function () {
    $('.container').hide();
});
