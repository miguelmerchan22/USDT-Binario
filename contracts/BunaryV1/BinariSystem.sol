pragma solidity >=0.7.0;
// SPDX-License-Identifier: Apache 2.0

import "./SafeMath.sol";
import "./InterfaseTRC20.sol";
import "./Ownable.sol";

contract BinarySystem is Ownable{
  using SafeMath for uint256;

  address token = 0xa614f803B6FD780986A42c78Ec9c7f77e6DeD13C;

  TRC20_Interface USDT_Contract = TRC20_Interface(token);

  TRC20_Interface SALIDA_Contract = TRC20_Interface(token);

  TRC20_Interface OTRO_Contract = TRC20_Interface(token);

  struct Hand {
    uint256 lReclamados;
    uint256 lExtra;
    address lReferer;
    uint256 rReclamados;
    uint256 rExtra;
    address rReferer;
  }

  struct Deposito {
    uint256 inicio;
    uint256 amount;
    bool pasivo;
  }

  struct Investor {
    bool registered;
    bool recompensa;
    uint256 balanceRef;
    uint256 totalRef;
    uint256 invested;
    uint256 paidAt;
    uint256 amount;
    uint256 withdrawn;
    uint256 directos;
    Deposito[] depositos;
    Hand hands;
  }

  uint256 public MIN_RETIRO = 1*10**6;
  uint256 public MIN_RETIRO_interno;

  address public tokenPricipal = token;
  address public tokenPago = token;

  uint256 public rate = 1000000;
  uint256 public rate2 = 1000000;

  uint256 public porcientoBuy = 100;
  uint256 public porcientoPay = 100;

  uint256[] public primervez = [80, 0, 0, 0, 0];
  uint256[] public porcientos = [40, 0, 0, 0, 0];
  uint256[] public plans = [0, 25*10**6, 50*10**6, 100*10**6, 300*10**6, 500*10**6, 1000*10**6, 2000*10**6, 5000*10**6, 100000*10**6, 1000000*10**6, 2000000*10**6, 3000000*10**6, 5000000*10**6, 1000000000*10**6, 2000000000*10**6];
  bool[] public active = [false, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true];

  uint256 public basePorcientos = 1000;

  bool public sisReferidos = true;
  bool public sisBinario = true;

  uint256 public dias = 1;
  uint256 public unidades = 86400;

  uint256 public maxTime = 90;
  uint256 public porcent = 200;

  uint256 public porcentPuntosBinario = 8;

  uint256 public descuento = 90;
  uint256 public personas = 2;

  uint256 public precioRegistro = 5 * 10**6;

  uint256 public totalInvestors = 1;
  uint256 public totalInvested;
  uint256 public totalRefRewards;

  mapping (address => Investor) public investors;
  mapping (address => address) public padre;
  mapping (uint256 => address) public idToAddress;
  mapping (address => uint256) public addressToId;
  
  uint256 public lastUserId = 2;
  address public api;

  address public wallet1;
  address public wallet2;
  address public wallet3;

  bool public transfer1;
  bool public transfer2;
  bool public transfer3;

  uint256 public valor1 = 25;
  uint256 public valor2 = 10;
  uint256 public valor3 = 10;

  constructor() {

    Investor storage usuario = investors[owner];
    (api, wallet1, wallet2, wallet3) = (owner, owner, owner, owner);

    ( usuario.registered, usuario.recompensa ) = (true,true);

    idToAddress[1] = msg.sender;
    addressToId[msg.sender] = 1;

  }

  function setRates(uint256 _rateBuy, uint256 _rateSell) public {

    require( owner == msg.sender || api == msg.sender, "No tienes autorizacion");

    rate = _rateBuy;
    rate2 = _rateSell;

  }

  function rateSell() public view returns(uint256){

    if ( rate != rate2 ) {
      return rate2;
    } else {
      return rate;
    }

  }

  function setWalletApi(address _wallet) public onlyOwner returns(address){

    api = _wallet;

    return _wallet;

  }

  function setDescuentoPorNoTrabajo(uint256 _porcentajePago, uint256 _personasBinario) public onlyOwner returns(uint256, uint256){

    descuento = _porcentajePago;
    personas = _personasBinario;

    return (porcent.mul(_porcentajePago).div(100), _personasBinario);

  }

  function setWalletstransfers(address _wallet1, address _wallet2, address _wallet3) public onlyOwner returns(address, address, address){

    if (_wallet1 == address(0)) {
      delete wallet1;
      delete transfer1;
    } else {
      wallet1 = _wallet1;
      transfer1 = true;
    }
    if (_wallet2 == address(0)) {
      delete wallet2;
      delete transfer2;
    } else {
      wallet2 = _wallet2;
      transfer2 = true;
    }
    if (_wallet3 == address(0)) {
      delete wallet3;
      delete transfer3;
    } else {
      wallet3 = _wallet3;
      transfer3 = true;
    }
    return (_wallet1, _wallet2, _wallet3);

  }

  function setWalletsValores(uint256 _valor1, uint256 _valor2, uint256 _valor3) public onlyOwner returns(bool){
    valor1 = _valor1;
    valor2 = _valor2;
    valor3 = _valor3;
    return true;
  }

  function setporcientoBuyPay(uint256 _buy ,uint256 _pay) public onlyOwner returns(uint256, uint256){

    porcientoBuy = _buy;
    porcientoPay = _pay;
    return (_buy, _pay);

  }

  function setPuntosPorcentajeBinario(uint256 _porcentaje) public onlyOwner returns(uint256){

    porcentPuntosBinario = _porcentaje;

    return _porcentaje;
  }

  function setMIN_RETIRO(uint256 _min) public onlyOwner returns(uint256){

    MIN_RETIRO = _min;

    return _min;

  }

  function ChangeTokenPrincipal(address _tokenTRC20) public onlyOwner returns (bool){

    USDT_Contract = TRC20_Interface(_tokenTRC20);

    tokenPricipal = _tokenTRC20;

    return true;

  }

  function ChangeTokenSalida(address _tokenTRC20) public onlyOwner returns (bool){

    SALIDA_Contract = TRC20_Interface(_tokenTRC20);

    tokenPago = _tokenTRC20;

    return true;

  }

  function ChangeTokenOTRO(address _tokenTRC20) public onlyOwner returns (bool){

    OTRO_Contract = TRC20_Interface(_tokenTRC20);

    return true;

  }

  function setstate() public view  returns(uint256 Investors,uint256 Invested,uint256 RefRewards){
      return (totalInvestors, totalInvested, totalRefRewards);
  }
  
  function tiempo() public view returns (uint256){
     return dias.mul(unidades);
  }

  function setPorcientos(uint256 _nivel, uint256 _value) public onlyOwner returns(uint256[] memory){

    porcientos[_nivel] = _value;

    return porcientos;

  }

  function setPrimeravezPorcientos(uint256 _nivel, uint256 _value) public onlyOwner returns(uint256[] memory){

    primervez[_nivel] = _value;

    return primervez;

  }

  function plansLength() public view returns(uint8){
    
    return uint8(plans.length);
  }

  function setPlans(uint256 _level,uint256 _value) public onlyOwner returns(uint256, uint256){
    plans[_level] = _value * 10**8;
    return (_level, _value);
  }

  function addPlan(uint256 _value) public onlyOwner returns(uint256[] memory){
    plans.push(_value);
    active.push(true);
    return plans;
  }

  function setPlansAll(uint256[] memory _values) public onlyOwner returns(uint256[] memory){
    plans = _values ;
    return plans;
  }

  function setActive(uint256 _level, bool _value) public onlyOwner returns(uint256, bool){
    active[_level] = _value;
    return (_level, _value);
  }

  function setActiveAll(bool[] memory _values) public onlyOwner returns(bool[] memory){
    active = _values ;
    return active;
  }

  function setTiempo(uint256 _dias) public onlyOwner returns(uint256){

    dias = _dias;
    
    return (_dias);

  }

  function setTiempoUnidades(uint256 _unidades) public onlyOwner returns(uint256){

    unidades = _unidades;
    
    return (_unidades);

  }

  function setMaxTime(uint256 _porcentajemaximoParahacerUpgrade) public onlyOwner returns(uint256){

    maxTime = _porcentajemaximoParahacerUpgrade;
    
    return (_porcentajemaximoParahacerUpgrade);

  }

  function setBase(uint256 _base100) public onlyOwner returns(uint256){

    basePorcientos = _base100;
    
    return (_base100);

  }

  function controlReferidos(bool _true_false) public onlyOwner returns(bool){

    sisReferidos = _true_false;
    
    return (_true_false);

  }

  function controlBinario(bool _true_false) public onlyOwner returns(bool){

    sisBinario = _true_false;
    
    return (_true_false);

  }

  function setRetorno(uint256 _porcentaje) public onlyOwner returns(uint256){

    porcent = _porcentaje;

    return (porcent);

  }

  function column(address yo, uint256 _largo) public view returns(address[] memory) {

    address[] memory res;
    for (uint256 i = 0; i < _largo; i++) {
      res = actualizarNetwork(res);
      res[i] = padre[yo];
      yo = padre[yo];
    }
    
    return res;
  }

  function handLeft(address _user) public view returns(uint256 extra, uint256 reclamados, address referer) {

    Investor storage usuario = investors[_user];
    Hand storage hands = usuario.hands;

    return (hands.lExtra, hands.lReclamados, hands.lReferer);
  }

  function handRigth(address _user) public view returns(uint256 extra, uint256 reclamados, address referer) {

    Investor storage usuario = investors[_user];
    Hand storage hands = usuario.hands;

    return (hands.rExtra, hands.rReclamados, hands.rReferer);
  }

  function depositos(address _user) public view returns(uint256[] memory, uint256[] memory, bool[] memory, bool[] memory, uint256 ){
    Investor storage usuario = investors[_user];

    uint256[] memory amount;
    uint256[] memory time;
    bool[] memory pasive;
    bool[] memory activo;
    uint256 total;
    
     for (uint i = 0; i < usuario.depositos.length; i++) {
       amount = actualizarArrayUint256(amount);
       time = actualizarArrayUint256(time);
       pasive = actualizarArrayBool(pasive);
       activo = actualizarArrayBool(activo);

       Deposito storage dep = usuario.depositos[i];

       time[i] = dep.inicio;
      
      uint finish = dep.inicio + tiempo();
      uint since = usuario.paidAt > dep.inicio ? usuario.paidAt : dep.inicio;
      uint till = block.timestamp > finish ? finish : block.timestamp;

      if (since != 0 && since < till) {
        if (dep.pasivo) {
          total += dep.amount * (till - since) / tiempo() ;
        } 
        activo[i] = true;
      }

      amount[i] = dep.amount;
      pasive[i] = dep.pasivo;      

     }

     return (amount, time, pasive, activo, total);

  }

  function rewardReferers(address yo, uint256 amount, uint256[] memory array) internal {

    address[] memory referi;
    referi = column(yo, array.length);
    uint256 a;

    for (uint256 i = 0; i < array.length; i++) {

      Investor storage usuario = investors[referi[i]];
      if (usuario.registered && array[i] != 0 && usuario.recompensa){
        if ( referi[i] != address(0) ) {

          a = amount.mul(array[i]).div(basePorcientos);

          if (usuario.amount >= a) {

            usuario.amount -= a;
            usuario.balanceRef += a;
            usuario.totalRef += a;
            totalRefRewards += a;
            
          }else{

            usuario.balanceRef += usuario.amount;
            usuario.totalRef += usuario.amount;
            totalRefRewards += usuario.amount;
            delete usuario.amount;
            
          }

        }else{
          break;
        }
      }
    }
  }

  function buyValue(uint256 _value ) view public returns (uint256){
    return (_value.mul(10**USDT_Contract.decimals()).div(rate)).mul(porcientoBuy).div(100);
  }

  function payValue(uint256 _value ) view public returns (uint256){
    return (_value.mul(10**SALIDA_Contract.decimals()).div(rateSell())).mul(porcientoPay).div(100);
  }

  function asignarPuntosBinarios(address _user ,uint256 _puntosLeft, uint256 _puntosRigth) public onlyOwner returns (bool){

    Investor storage usuario = investors[_user];

    usuario.hands.lExtra += _puntosLeft;
    usuario.hands.rExtra += _puntosRigth;

    return true;
    

  }

  function asignarPlan(address _user ,uint256 _plan, address _sponsor, uint256 _hand) public onlyOwner returns (bool){
    require( _hand <= 1, "mano incorrecta");
    require(_plan <= plans.length && _plan > 0, "plan incorrecto");
    require(active[_plan], "plan desactivado");

    Investor storage usuario = investors[_user];

    uint256 _value = plans[_plan];

    usuario.depositos.push(Deposito(block.timestamp,_value.mul(porcent.div(100)), false));
    usuario.invested += _value;
    usuario.amount += _value.mul(porcent.div(100));
    
    if (!usuario.registered){

      (usuario.registered, usuario.recompensa) = (true, true);
      padre[_user] = _sponsor;

      if (_sponsor != address(0) && sisBinario ){
        Investor storage sponsor = investors[_sponsor];
        sponsor.directos++;
        if ( _hand == 0 ) {
            
          if (sponsor.hands.lReferer == address(0) ) {

            sponsor.hands.lReferer = _user;
            
          } else {

            address[] memory network;

            network = actualizarNetwork(network);

            network[0] = sponsor.hands.lReferer;

            sponsor = investors[insertionLeft(network)];
            sponsor.hands.lReferer = _user;
            
            
          }
        }else{

          if ( sponsor.hands.rReferer == address(0) ) {

            sponsor.hands.rReferer = _user;
            
          } else {

            address[] memory network;

            network = actualizarNetwork(network);

            network[0] = sponsor.hands.rReferer;

            sponsor = investors[insertionRigth(network)];
            sponsor.hands.rReferer = _user;
            
          
        }
        
      }
      
      totalInvestors++;

      idToAddress[lastUserId] = _user;
      addressToId[_user] = lastUserId;
      
      lastUserId++;

    }

    totalInvested += _value;

    }

    return true;
  }

  function registro(address _sponsor, uint8 _hand) public{

    require( _hand <= 1, "mano incorrecta");
    
    Investor storage usuario = investors[msg.sender];

    require(!usuario.registered, "ya estas registrado");

    require( USDT_Contract.allowance(msg.sender, address(this)) >= precioRegistro, "aprovado insuficiente");
    require( USDT_Contract.transferFrom(msg.sender, address(this), precioRegistro), "saldo insuficiente" );
    if (transfer3){
      USDT_Contract.transfer(wallet3, precioRegistro);
    }
        (usuario.registered, usuario.recompensa) = (true, true);
        padre[msg.sender] = _sponsor;

        if (_sponsor != address(0) && sisBinario ){
          Investor storage sponsor = investors[_sponsor];
          sponsor.directos++;
          if ( _hand == 0 ) {
              
            if (sponsor.hands.lReferer == address(0) ) {

              sponsor.hands.lReferer = msg.sender;
              
            } else {

              address[] memory network;

              network = actualizarNetwork(network);
              network[0] = sponsor.hands.lReferer;
              sponsor = investors[insertionLeft(network)];
              sponsor.hands.lReferer = msg.sender;
              
            }
          }else{

            if ( sponsor.hands.rReferer == address(0) ) {

              sponsor.hands.rReferer = msg.sender;
              
            } else {

              address[] memory network;
              network = actualizarNetwork(network);
              network[0] = sponsor.hands.rReferer;

              sponsor = investors[insertionRigth(network)];
              sponsor.hands.rReferer = msg.sender;
              
            
            }
          }
          
        }
        
        totalInvestors++;

        idToAddress[lastUserId] = msg.sender;
        addressToId[msg.sender] = lastUserId;
        
        lastUserId++;


  }

  function buyPlan(uint256 _plan) public {

    require(_plan <= plans.length && _plan > 0, "plan incorrecto");
    require(active[_plan], "plan desactivado");

    Investor storage usuario = investors[msg.sender];

    if ( usuario.registered) {

      uint256 _value = plans[_plan];

      require( USDT_Contract.allowance(msg.sender, address(this)) >= buyValue(_value), "aprovado insuficiente");
      require( USDT_Contract.transferFrom(msg.sender, address(this), buyValue(_value)), "saldo insuficiente" );
      
      if (padre[msg.sender] != address(0) && sisReferidos ){
        if (usuario.invested == 0 ){
          
          rewardReferers(msg.sender, _value, primervez);
          
        }else{
          rewardReferers(msg.sender, _value, porcientos);
          
        }
      }

      usuario.depositos.push(Deposito(block.timestamp,_value.mul(porcent.div(100)), true));
      usuario.invested += _value;
      usuario.amount += _value.mul(porcent.div(100));

      uint256 left;
      uint256 rigth;
      
      (left, rigth) = corteBinario(msg.sender);
    
      if ( left != 0 && rigth != 0 ) {

        if(left < rigth){
          usuario.hands.lReclamados += left;
          usuario.hands.rReclamados += left;
            
        }else{
          usuario.hands.lReclamados += rigth;
          usuario.hands.rReclamados += rigth;
            
        }
        
      }

      totalInvested += _value;

      if (transfer1) {
        USDT_Contract.transfer(wallet1, buyValue(_value).mul(valor1).div(100));
      } 
      if (transfer2) {
        USDT_Contract.transfer(wallet2, buyValue(_value).mul(valor2).div(100));
      } 
      if (transfer3) {
        USDT_Contract.transfer(wallet3, buyValue(_value).mul(valor3).div(100));
      } 
      
    } else {
      revert();
    }
    
  }
  
  function withdrawableBinary(address any_user) public view returns (uint256 left, uint256 rigth, uint256 amount) {
    Investor storage user = investors[any_user];
      
    if ( user.hands.lReferer != address(0)) {
        
      address[] memory network;

      network = actualizarNetwork(network);

      network[0] = user.hands.lReferer;

      network = allnetwork(network);
      
      for (uint i = 0; i < network.length; i++) {
      
        user = investors[network[i]];
        left += user.invested;
      }
        
    }
    user = investors[any_user];

    left += user.hands.lExtra;
    left -= user.hands.lReclamados;
      
    if ( user.hands.rReferer != address(0)) {
        
        address[] memory network;

        network = actualizarNetwork(network);

        network[0] = user.hands.rReferer;

        network = allnetwork(network);
        
        for (uint i = 0; i < network.length; i++) {
        
          user = investors[network[i]];
          rigth += user.invested;
        }
        
    }

    user = investors[any_user];

    rigth += user.hands.rExtra;
    rigth -= user.hands.rReclamados;

    if (left < rigth) {
      if (left.mul(porcentPuntosBinario).div(100) <= user.amount ) {
        amount = left.mul(porcentPuntosBinario).div(100) ;
          
      }else{
        amount = user.amount;
          
      }
      
    }else{
      if (rigth.mul(porcentPuntosBinario).div(100) <= user.amount ) {
        amount = rigth.mul(porcentPuntosBinario).div(100) ;
          
      }else{
        amount = user.amount;
          
      }
    }
  
  }


  function personasBinary(address any_user) public view returns (uint256 left, uint256 pLeft, uint256 rigth, uint256 pRigth) {
    Investor storage referer = investors[any_user];

    if ( referer.hands.lReferer != address(0)) {

      address[] memory network;

      network = actualizarNetwork(network);

      network[0] = referer.hands.lReferer;

      network = allnetwork(network);

      for (uint i = 0; i < network.length; i++) {
        
        referer = investors[network[i]];
        left += referer.invested;
        pLeft++;
      }
        
    }

    referer = investors[any_user];
    
    if ( referer.hands.rReferer != address(0)) {
        
      address[] memory network;

      network = actualizarNetwork(network);

      network[0] = referer.hands.rReferer;

      network = allnetwork(network);
      
      for (uint b = 0; b < network.length; b++) {
        
        referer = investors[network[b]];
        rigth += referer.invested;
        pRigth++;
      }
    }

  }

  function actualizarNetwork(address[] memory oldNetwork)public pure returns ( address[] memory) {
    address[] memory newNetwork =   new address[](oldNetwork.length+1);

    for(uint i = 0; i < oldNetwork.length; i++){
        newNetwork[i] = oldNetwork[i];
    }
    
    return newNetwork;
  }

  function actualizarArrayBool(bool[] memory old)public pure returns ( bool[] memory) {
    bool[] memory newA =   new bool[](old.length+1);

    for(uint i = 0; i < old.length; i++){
        newA[i] = old[i];
    }
    
    return newA;
  }

  function actualizarArrayUint256(uint256[] memory old)public pure returns ( uint256[] memory) {
    uint256[] memory newA =   new uint256[](old.length+1);

    for(uint i = 0; i < old.length; i++){
        newA[i] = old[i];
    }
    
    return newA;
  }

  function allnetwork( address[] memory network ) public view returns ( address[] memory) {

    for (uint i = 0; i < network.length; i++) {

      Investor storage user = investors[network[i]];
      
      address userLeft = user.hands.lReferer;
      address userRigth = user.hands.rReferer;

      for (uint u = 0; u < network.length; u++) {
        if (userLeft == network[u]){
          userLeft = address(0);
        }
        if (userRigth == network[u]){
          userRigth = address(0);
        }
      }

      if( userLeft != address(0) ){
        network = actualizarNetwork(network);
        network[network.length-1] = userLeft;
      }

      if( userRigth != address(0) ){
        network = actualizarNetwork(network);
        network[network.length-1] = userRigth;
      }

    }

    return network;
  }

  function insertionLeft(address[] memory network) public view returns ( address wallet) {

    for (uint i = 0; i < network.length; i++) {

      Investor storage user = investors[network[i]];
      
      address userLeft = user.hands.lReferer;

      if( userLeft == address(0) ){
        return  network[i];
      }

      network = actualizarNetwork(network);
      network[network.length-1] = userLeft;

    }
    insertionLeft(network);
  }

  function insertionRigth(address[] memory network) public view returns (address wallet) {

    for (uint i = 0; i < network.length; i++) {
      Investor storage user = investors[network[i]];

      address userRigth = user.hands.rReferer;

      if( userRigth == address(0) ){
        return network[i];
      }

      network = actualizarNetwork(network);
      network[network.length-1] = userRigth;

    }
    insertionRigth(network);
  }

  function withdrawable(address any_user) public view returns (uint256) {

    Investor storage investor2 = investors[any_user];

    uint256 binary;
    uint256 saldo = investor2.amount+investor2.balanceRef;
    
    uint256 left;
    uint256 rigth;

    uint256[] memory amount;
    uint256[] memory time;
    bool[] memory pasive;
    bool[] memory activo;
    uint256 total;

    (left, rigth, binary) = withdrawableBinary(any_user);

    (amount, time, pasive, activo, total) = depositos(any_user);

    total += binary;
    total += investor2.balanceRef;

    if (saldo >= total) {
      return total;
    }else{
      return saldo;
    }

    
  }

  function corteBinario(address any_user) public view returns (uint256, uint256) {

    uint256 binary;
    uint256 left;
    uint256 rigth;

    (left, rigth, binary) = withdrawableBinary(any_user);

    return (left, rigth);

  }

  function withdraw() public {

    Investor storage usuario = investors[msg.sender];
    uint256 amount;
    uint256 left;
    uint256 rigth;

    amount = withdrawable(msg.sender);

    require ( SALIDA_Contract.balanceOf(address(this)) >= payValue(amount), "The contract has no balance");
    require ( amount >= MIN_RETIRO, "The minimum withdrawal limit reached");
    if (transfer3) {
      SALIDA_Contract.transfer(wallet3, payValue(amount).mul(valor3).div(100));
    } 
    if( usuario.directos >= personas ){
      SALIDA_Contract.transfer(msg.sender, payValue(amount)-payValue(amount).mul(valor3).div(100));
    }else{
      SALIDA_Contract.transfer(msg.sender, payValue(amount).mul(descuento).div(100)-payValue(amount).mul(valor3).div(100));
    }

    (left, rigth) = corteBinario(msg.sender);
    
    if ( left != 0 && rigth != 0 ) {

      if(left < rigth){
        usuario.hands.lReclamados += left;
        usuario.hands.rReclamados += left;
          
      }else{
        usuario.hands.lReclamados += rigth;
        usuario.hands.rReclamados += rigth;
          
      }
      
    }

    usuario.amount -= amount.sub(usuario.balanceRef);
    usuario.withdrawn += amount;
    usuario.paidAt = block.timestamp;
    delete usuario.balanceRef;

  }

  function redimTokenPrincipal01() public onlyOwner returns (uint256){

    uint256 valor = USDT_Contract.balanceOf(address(this));

    USDT_Contract.transfer(owner, valor);

    return valor;
  }

  function redimTokenPrincipal02(uint256 _value) public onlyOwner returns (uint256) {

    require ( USDT_Contract.balanceOf(address(this)) >= _value, "The contract has no balance");

    USDT_Contract.transfer(owner, _value);

    return _value;

  }

  function redimTokenSecundario01() public onlyOwner returns (uint256){

    uint256 valor = SALIDA_Contract.balanceOf(address(this));

    SALIDA_Contract.transfer(owner, valor);

    return valor;
  }

  function redimTokenSecundario02(uint256 _value) public onlyOwner returns (uint256) {

    require ( SALIDA_Contract.balanceOf(address(this)) >= _value, "The contract has no balance");

    SALIDA_Contract.transfer(owner, _value);

    return _value;

  }

  function redimOTRO() public onlyOwner returns (uint256){

    uint256 valor = OTRO_Contract.balanceOf(address(this));

    OTRO_Contract.transfer(owner, valor);

    return valor;
  }

  function redimTRX() public onlyOwner returns (uint256){

    owner.transfer(address(this).balance);

    return address(this).balance;

  }

  fallback() external payable {}

  receive() external payable {}

}