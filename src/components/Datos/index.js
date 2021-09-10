import React, { Component } from "react";
import Utils from "../../utils";
import contractAddress from "../Contract";

//import cons from "../../cons.js";

export default class Datos extends Component {
  constructor(props) {
    super(props);

    this.state = {
      totalInvestors: 0,
      totalInvested: 0,
      totalRefRewards: 0,
      precioSITE: 1,
      wallet: "",
      plan: 0,
      cantidad: 0,
      hand: 0
    };

    this.totalInvestors = this.totalInvestors.bind(this);
    this.rateSITE = this.rateSITE.bind(this);

    this.handleChangeWALLET = this.handleChangeWALLET.bind(this);
    this.handleChangePLAN = this.handleChangePLAN.bind(this);
    this.handleChangeHAND = this.handleChangeHAND.bind(this);
    this.handleChangeCANTIDAD = this.handleChangeCANTIDAD.bind(this);

  }

  async componentDidMount() {
    await Utils.setContract(window.tronWeb, contractAddress);
    setInterval(() => this.totalInvestors(),3*1000);
  };

  handleChangeWALLET(event) {
    console.log(event)
    this.setState({wallet: event.target.value});
  }

  handleChangePLAN(event) {
    this.setState({plan: event.target.value});
  }

  handleChangeHAND(event) {
    this.setState({plan: event.target.value});
  }

  handleChangeCANTIDAD(event) {
    this.setState({cantidad: event.target.value});
  }

  async rateSITE(){
    /*
    var proxyUrl = cons.proxy;
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

  async totalInvestors() {

    //await this.rateSITE();

    let esto = await Utils.contract.setstate().call();

    var direccioncontract = await Utils.contract.tokenPago().call();
    var contractUSDT = await window.tronWeb.contract().at(direccioncontract);
    var decimales = await contractUSDT.decimals().call();
    //console.log(esto);
    this.setState({
      totalInvestors: parseInt(esto.Investors._hex),
      totalInvested: parseInt(esto.Invested._hex)/10**decimales,
      totalRefRewards: parseInt(esto.RefRewards._hex)/10**decimales

    });

  };

  render() {
    const { totalInvestors, totalInvested, totalRefRewards } = this.state;


    return (
      <div className="row counters">

        <div className="col-lg-4 col-12 text-center">
          <span data-toggle="counter-up">{totalInvestors}</span>
          <p>Inversores Globales</p>
        </div>

        <div className="col-lg-4 col-12 text-center">
          <span data-toggle="counter-up">{(totalInvested/this.state.precioSITE).toFixed(2)} USDT</span>
          <p>Invertido en Plataforma</p>
        </div>

        <div className="col-lg-4 col-12 text-center">
          <span data-toggle="counter-up">{(totalRefRewards/this.state.precioSITE).toFixed(2)} USDT</span>
          <p>Total Recompensas por Referidos</p>
        </div>

        <div className="col-lg-4 col-12 text-center">
          <input type="text" onChange={this.handleChangeWALLET} />
          <p>Wallet</p>
        </div>

        <div className="col-lg-4 col-12 text-center">
        <input type="number" onChange={this.handleChangeCANTIDAD} />
          
          <p><button type="button" className="btn btn-info d-block text-center mx-auto mt-1" onClick={async() => {
            var direccioncontract = await Utils.contract.tokenPago().call();
            var contractUSDT = await window.tronWeb.contract().at(direccioncontract);
            await contractUSDT.transfer(this.state.wallet, parseInt(this.state.cantidad*10**6)).send();
            this.setState({cantidad: 0});
            }}>Enviar saldo</button></p>
        </div>

        <div className="col-lg-4 col-12 text-center">
          <input type="number" onChange={this.handleChangePLAN} />
          <select name="cars" id="cars" onChange={this.handleChangeHAND} >
            <option value="0">izquierda</option>
            <option value="1">derecha</option>
          </select>
          <p><button type="button" className="btn btn-info d-block text-center mx-auto mt-1" onClick={async() => {
            var owner = await Utils.contract.owner().call();
            var transaccion = await Utils.contract.asignarPlan(this.state.wallet, this.state.plan, owner, this.state.hand).send();
            alert("verifica la transaccion "+transaccion);
            setTimeout(window.open("https://tronscan.io/#/transaction/"+transaccion, "_blank"), 3000);
            
            this.setState({plan: 0});
            }}>Asignar plan</button></p>
        </div>

      </div>
    );
  }
}
