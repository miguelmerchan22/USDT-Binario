import React, { Component } from "react";
import {CopyToClipboard} from 'react-copy-to-clipboard';
import Utils from "../../utils";
import contractAddress from "../Contract";

//import cons from "../../cons.js";
//import utils from "../../utils";

export default class Oficina extends Component {
  constructor(props) {
    super(props);

    this.state = {
      direccion: "",
      link: "Haz una inversión para obtener el LINK de referido",
      registered: false,
      balanceRef: 0,
      totalRef: 0,
      invested: 0,
      paidAt: 0,
      my: 0,
      almacen: 0,
      withdrawn: 0,
      precioSITE: 1,
      valueSITE: 0,
      valueUSDT: 0,
      personasIzquierda: 0,
      puntosIzquierda: 0,
      personasDerecha: 0,
      puntosDerecha: 0,
      bonusBinario: 0,
      puntosEfectivosIzquierda: 0,
      puntosEfectivosDerecha: 0,
      puntosReclamadosIzquierda: 0,
      puntosReclamadosDerecha: 0,
      puntosLostIzquierda: 0,
      puntosLostDerecha: 0,
      directos: 0,

    };

    this.Investors = this.Investors.bind(this);
    this.Investors2 = this.Investors2.bind(this);
    this.Investors3 = this.Investors3.bind(this);
    this.Link = this.Link.bind(this);
    this.withdraw = this.withdraw.bind(this);

    this.rateSITE = this.rateSITE.bind(this);
    this.handleChangeSITE = this.handleChangeSITE.bind(this);
    this.handleChangeUSDT = this.handleChangeUSDT.bind(this);
  }

  handleChangeSITE(event) {
    this.setState({valueSITE: event.target.value});
  }

  handleChangeUSDT(event) {
    this.setState({valueUSDT: event.target.value});
  }

  async componentDidMount() {
    await Utils.setContract(window.tronWeb, contractAddress);
    setInterval(() => this.Investors2(),3*1000);
    setInterval(() => this.Investors3(),3*1000);
    setInterval(() => this.Investors(),3*1000);
    setInterval(() => this.Link(),3*1000);
  };

  async rateSITE(){
    /*var proxyUrl = cons.proxy;
    var apiUrl = cons.PRE;
    var response;

    try {
      response = await fetch(proxyUrl+apiUrl);
    } catch (err) {
      console.log(err);
      return this.state.precioSITE;
    }

    var json = await response.json();

    this.setState({
      precioSITE: json.Data.precio
    });

    return json.Data.precio;*/

    return 1;

  };

  async Link() {
    const {registered} = this.state;
    if(registered){

      let loc = document.location.href;
      if(loc.indexOf('?')>0){
        loc = loc.split('?')[0];
      }

      if(loc.indexOf('#')>0){
        loc = loc.split('#')[0];
      }
      let mydireccion = window.tronWeb.defaultAddress.base58;
      mydireccion = await Utils.contract.addressToId(mydireccion).call();
      mydireccion = loc+'?ref='+mydireccion;
      var link = mydireccion+"&hand=izq";
      var link2 = mydireccion+"&hand=der";
      this.setState({
        link: link,
        link2: link2,
      });
    }else{
      this.setState({
        link: "Haz una inversión para obtener el LINK de referido",
        link2: "Haz una inversión para obtener el LINK de referido",
      });
    }
  }


  async Investors() {

    let direccion = window.tronWeb.defaultAddress.base58;
    let usuario = await Utils.contract.investors(direccion).call();
    usuario.withdrawable = await Utils.contract.withdrawable(direccion).call();
    
    var tronUSDT = await window.tronWeb;
    var direccioncontract = await Utils.contract.tokenPricipal().call();
    var contractUSDT = await tronUSDT.contract().at(direccioncontract); 
    var decimales = await contractUSDT.decimals().call();

    //console.log(usuario);

    usuario.amount = parseInt(usuario.amount._hex);
    usuario.invested = parseInt(usuario.invested);
    usuario.withdrawn = parseInt(usuario.withdrawn._hex);
    usuario.directos = parseInt(usuario.directos);
    usuario.balanceRef = parseInt(usuario.balanceRef);
    usuario.totalRef = parseInt(usuario.totalRef._hex);
    usuario.paidAt = parseInt(usuario.paidAt._hex);
    usuario.withdrawable = parseInt(usuario.withdrawable._hex);

    //console.log(usuario);

    let porcent = await Utils.contract.porcent().call();
    porcent = parseInt(porcent._hex)/100;

    var valorPlan = (usuario.invested*porcent);// decimales visuales

    var progresoUsdt = ((valorPlan-(usuario.invested*porcent-(usuario.withdrawn+usuario.withdrawable)))*100)/valorPlan;

    var progresoRetiro = ((valorPlan-(usuario.invested*porcent-usuario.withdrawn))*100)/valorPlan;


    this.setState({
      direccion: window.tronWeb.address.fromHex(direccion.address),
      registered: usuario.registered,
      balanceRef: usuario.balanceRef/10**decimales,
      totalRef: usuario.totalRef/10**decimales,
      invested: usuario.invested/10**decimales,
      paidAt: usuario.paidAt/10**decimales,
      my: usuario.withdrawable/10**decimales,
      withdrawn: usuario.withdrawn/10**decimales,
      almacen: usuario.almacen/10**decimales,
      progresoUsdt: progresoUsdt,
      progresoRetiro: progresoRetiro,
      valorPlan: valorPlan/10**decimales,
      directos: usuario.directos
    });

  };

  async Investors2() {

    //var precioSITE = await this.rateSITE();

    /*this.setState({
      precioSITE: precioSITE
    });*/

  };

  async Investors3() {

    var {directos, valorPlan } = this.state;

    let direccion = window.tronWeb.defaultAddress.base58;

    //Personas y puntos totales
    let puntos = await Utils.contract.personasBinary(direccion).call();

    // monto de bonus y puntos efectivos
    let bonusBinario = await Utils.contract.withdrawableBinary(direccion).call();
  
    var available = await Utils.contract.withdrawable(direccion).call();
    //console.log(available);
    available = parseInt(available._hex)/10**6;
    //console.log(available);


    if(directos >= 2 && available < valorPlan ){
      bonusBinario.amount = parseInt(bonusBinario.amount._hex)/10**6;
    }else{
      bonusBinario.amount = 0;
    }

    let brazoIzquierdo = await Utils.contract.handLeft(direccion).call();

    let brazoDerecho = await Utils.contract.handRigth(direccion).call();

    //console.log(brazoDerecho);

    this.setState({
      personasIzquierda: parseInt(puntos.pLeft._hex),
      personasDerecha: parseInt(puntos.pRigth._hex),

      puntosIzquierda: parseInt(puntos.left._hex)/10**6,
      puntosDerecha: parseInt(puntos.rigth._hex)/10**6,

      bonusBinario: bonusBinario.amount,

      puntosEfectivosIzquierda: parseInt(bonusBinario.left._hex)/10**6,
      puntosEfectivosDerecha: parseInt(bonusBinario.rigth._hex)/10**6,

      puntosReclamadosIzquierda: parseInt(brazoIzquierdo.reclamados._hex)/10**6,
      puntosReclamadosDerecha: parseInt(brazoDerecho.reclamados._hex)/10**6,

      available:available

    });

  };

  async withdraw(){
    var {available} = this.state;

    available = (available*1).toFixed(6);
    available = parseFloat(available);

    var direccioncontract = await Utils.contract.tokenPricipal().call();
    var contractUSDT = await window.tronWeb.contract().at(direccioncontract);

    var decimales = await contractUSDT.decimals().call();

    var MIN_RETIRO = await Utils.contract.MIN_RETIRO().call();
    MIN_RETIRO = parseInt(MIN_RETIRO._hex)/10**decimales;

    if ( available > MIN_RETIRO ){
      await Utils.contract.withdraw().send();
    }else{
      if (available < MIN_RETIRO) {
        window.alert("El minimo para retirar son: "+(MIN_RETIRO)+" USDT");
      }
    }
  };


  render() {
    var { available, balanceRef, invested, my, direccion, link, link2, almacen, valorPlan, directos, bonusBinario} = this.state;

    
    available = (available*1).toFixed(2);
    available = parseFloat(available);

    balanceRef = balanceRef.toFixed(2);
    balanceRef = parseFloat(balanceRef);

    invested = invested.toFixed(2);
    invested = parseFloat(invested);

    my = my.toFixed(2);
    my = parseFloat(my);

    return (

      <div className="container">

        <header style={{'textAlign': 'center'}} className="section-header">
          <h3 className="white">
            <i className="fa fa-user mr-2" aria-hidden="true"></i>
            <span style={{'fontWeight': 'bold'}}>
              Mi Oficina:
            </span>
          </h3>
          <div className="row text-center">
            <div className="col-md-12 col-lg-10 offset-lg-1 wow bounceInUp" data-wow-duration="1s">
              <div className="box">
                <h4 className="title"><a href={"https://tronscan.io/#/address/"+direccion} style={{"wordWrap": "break-word"}}>{direccion}</a></h4>
               
                <br></br>
                <b>{(this.state.withdrawn+available).toFixed(2)} USDT</b> ganancias de <b>{this.state.valorPlan} USDT</b>
                <div className="progress" style={{"height": "20px"}}>
                  <div className="progress-bar bg-info " role="progressbar" style={{"width": this.state.progresoUsdt+"%"}} aria-valuenow={this.state.progresoUsdt} aria-valuemin="0" aria-valuemax="100"></div>
                </div>
    
                <div className="progress" style={{"height": "20px"}}>
                  <div className="progress-bar bg-warning " role="progressbar" style={{"width": this.state.progresoRetiro+"%"}} aria-valuenow={this.state.progresoRetiro} aria-valuemin="0" aria-valuemax="100"></div>
                </div>
                Reclamados <b>{(this.state.withdrawn).toFixed(2)} USDT</b>

                <br></br>
                <button type="button" className="btn btn-success d-block text-center mx-auto mt-1" onClick={() => document.getElementById("why-us").scrollIntoView({block: "end", behavior: "smooth"}) }>Upgrade Plan</button>


              </div>
            </div>

            <div className="col-md-5 offset-lg-1" >
              <h3 className="white" style={{'fontWeight': 'bold'}}><i className="fa fa-arrow-left mr-2" aria-hidden="true"></i>Mano izquierda</h3>
              <h6 className="white" style={{'padding': '1.5em', 'fontSize': '11px'}}><a href={link}>{link}</a> <br /><br />
              <CopyToClipboard text={link}>
                <button type="button" className="btn btn-info">COPIAR</button>
              </CopyToClipboard>
              </h6>
              <hr></hr>
            </div>

            <div className="col-md-5 " >
              <h3 className="white" style={{'fontWeight': 'bold'}}>Mano derecha <i className="fa fa-arrow-right mr-2" aria-hidden="true"></i></h3>
              <h6 className="white" style={{'padding': '1.5em', 'fontSize': '11px'}}><a href={link2}>{link2}</a> <br /><br />
              <CopyToClipboard text={link2}>
                <button type="button" className="btn btn-info">COPIAR</button>
              </CopyToClipboard>
              </h6>
              <hr></hr>
            </div>
          </div>

        </header>

        <div className="row text-center">
          <div className="col-md-6 col-lg-5 offset-lg-1 wow bounceInUp" data-wow-delay="0.1s" data-wow-duration="1s">
            <div className="box">
              <div className="icon"><i className="ion-ios-paper-outline" style={{color: '#3fcdc7'}}></i></div>
              <p className="description">Equipo Izquierdo ({this.state.personasIzquierda})</p>
              <h4 className="title"><a href="#services">Disponible {this.state.puntosEfectivosIzquierda} pts</a></h4>
              <p className="description">Reclamado {this.state.puntosReclamadosIzquierda} pts</p>
              <hr />
              <p className="description">Total {this.state.puntosIzquierda} pts</p>


            </div>
          </div>
          <div className="col-md-6 col-lg-5 wow bounceInUp" data-wow-delay="0.1s" data-wow-duration="1s">
            <div className="box">
              <div className="icon"><i className="ion-ios-paper-outline" style={{color: '#3fcdc7'}}></i></div>
              <p className="description">Equipo Derecho ({this.state.personasDerecha})</p>
              <h4 className="title"><a href="#services">Disponible {this.state.puntosEfectivosDerecha} pts</a></h4>
              <p className="description">Reclamado {this.state.puntosReclamadosDerecha} pts</p>
              <hr />
              <p className="description">Total {this.state.puntosDerecha} pts</p>

            </div>
          </div>

          <div className="col-md-6 col-lg-5 offset-lg-1 wow bounceInUp" data-wow-duration="1s">
            <div className="box">
              <div className="icon"><i className="ion-ios-speedometer-outline" style={{color: '#ff689b'}}></i></div>
              
              <h4 className="title"><a href="#services">Disponible {available} USDT</a></h4>
                
              <button type="button" className="btn btn-info d-block text-center mx-auto mt-1" onClick={() => this.withdraw()}>Retirar ~ {(available/this.state.precioSITE).toFixed(2)} USDT</button>
                 
              
              <hr></hr>
              <p className="description">Retirado <b>{(this.state.withdrawn).toFixed(2)} USDT</b> </p>
              <p className="description">Total invertido <b>{invested} USDT</b> </p>
            </div>
          </div>
          <div className="col-md-6 col-lg-5 wow bounceInUp" data-wow-duration="1s">
            <div className="box">
              <div className="icon"><i className="ion-ios-analytics-outline" style={{color: '#ff689b'}}></i></div>
              <p className="description">Bonus </p>
              <h4 className="title"><a href="#services">{(this.state.balanceRef+this.state.bonusBinario).toFixed(2)} USDT</a></h4>
              <hr></hr>
              <p className="description">({this.state.directos}) Referidos directos <b>{(this.state.balanceRef).toFixed(2)} USDT</b> </p>
              <p className="description">({this.state.personasDerecha+this.state.personasIzquierda}) Red binaria <b>{(this.state.bonusBinario).toFixed(2)} USDT</b> </p>
              
            </div>
          </div>

        </div>

      </div>

    );
  }
}
