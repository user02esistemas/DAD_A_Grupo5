/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package entidades;

import javax.persistence.Basic;
import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

@Entity
@Table(name = "Pedidos", catalog = "Grupo05_DDA_PAF", schema = "dbo")
@NamedQueries({
    @NamedQuery(name = "Pedidos.findAll", query = "SELECT p FROM Pedidos p"),
    @NamedQuery(name = "Pedidos.findByIdPedido", query = "SELECT p FROM Pedidos p WHERE p.idPedido = :idPedido")})
public class Pedidos implements Serializable {

    private static final long serialVersionUID = 1L;
    
    // --- CORRECCIÓN AQUÍ ---
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // <--- ESTO FALTABA
    @Basic(optional = false)
    @Column(name = "id_pedido", nullable = false)
    private Integer idPedido;
    // -----------------------

    @Column(name = "fecha_recepcion")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaRecepcion;
    
    @Column(name = "fecha_entrega_estimada")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaEntregaEstimada;
    
    @Column(name = "estado", length = 50)
    private String estado;
    
    @Column(name = "monto_total", precision = 10, scale = 2)
    private BigDecimal montoTotal;
    
    @Column(name = "monto_pagado", precision = 10, scale = 2)
    private BigDecimal montoPagado;
    
    @Column(name = "estado_pago", length = 50)
    private String estadoPago;
    
    @Column(name = "notas_adicionales", length = 2147483647)
    private String notasAdicionales;
    
    @Column(name = "empleado_receptor", length = 100)
    private String empleadoReceptor;
    
    @Column(name = "fecha_actualizacion")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaActualizacion;
    
    @JoinColumn(name = "id_cliente", referencedColumnName = "id_cliente", nullable = false)
    @ManyToOne(optional = false)
    private Clientes idCliente;
    
    @JoinColumn(name = "id_empleado", referencedColumnName = "id_usuario")
    @ManyToOne
    private Empleados idEmpleado;
    
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "idPedido")
    private List<DetallePedido> detallePedidoList;
    
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "idPedido")
    private List<Pagos> pagosList;

    public Pedidos() {
    }

    public Pedidos(Integer idPedido) {
        this.idPedido = idPedido;
    }

    public Integer getIdPedido() { return idPedido; }
    public void setIdPedido(Integer idPedido) { this.idPedido = idPedido; }

    public Date getFechaRecepcion() { return fechaRecepcion; }
    public void setFechaRecepcion(Date fechaRecepcion) { this.fechaRecepcion = fechaRecepcion; }

    public Date getFechaEntregaEstimada() { return fechaEntregaEstimada; }
    public void setFechaEntregaEstimada(Date fechaEntregaEstimada) { this.fechaEntregaEstimada = fechaEntregaEstimada; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public BigDecimal getMontoTotal() { return montoTotal; }
    public void setMontoTotal(BigDecimal montoTotal) { this.montoTotal = montoTotal; }

    public BigDecimal getMontoPagado() { return montoPagado; }
    public void setMontoPagado(BigDecimal montoPagado) { this.montoPagado = montoPagado; }

    public String getEstadoPago() { return estadoPago; }
    public void setEstadoPago(String estadoPago) { this.estadoPago = estadoPago; }

    public String getNotasAdicionales() { return notasAdicionales; }
    public void setNotasAdicionales(String notasAdicionales) { this.notasAdicionales = notasAdicionales; }

    public String getEmpleadoReceptor() { return empleadoReceptor; }
    public void setEmpleadoReceptor(String empleadoReceptor) { this.empleadoReceptor = empleadoReceptor; }

    public Date getFechaActualizacion() { return fechaActualizacion; }
    public void setFechaActualizacion(Date fechaActualizacion) { this.fechaActualizacion = fechaActualizacion; }

    public Clientes getIdCliente() { return idCliente; }
    public void setIdCliente(Clientes idCliente) { this.idCliente = idCliente; }

    public Empleados getIdEmpleado() { return idEmpleado; }
    public void setIdEmpleado(Empleados idEmpleado) { this.idEmpleado = idEmpleado; }

    public List<DetallePedido> getDetallePedidoList() { return detallePedidoList; }
    public void setDetallePedidoList(List<DetallePedido> detallePedidoList) { this.detallePedidoList = detallePedidoList; }

    public List<Pagos> getPagosList() { return pagosList; }
    public void setPagosList(List<Pagos> pagosList) { this.pagosList = pagosList; }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (idPedido != null ? idPedido.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        if (!(object instanceof Pedidos)) return false;
        Pedidos other = (Pedidos) object;
        if ((this.idPedido == null && other.idPedido != null) || (this.idPedido != null && !this.idPedido.equals(other.idPedido))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "entidades.Pedidos[ idPedido=" + idPedido + " ]";
    }
}
