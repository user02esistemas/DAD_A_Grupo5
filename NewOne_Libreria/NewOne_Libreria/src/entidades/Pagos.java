/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package entidades;

import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

/**
 *
 * @author diego
 */
@Entity
@Table(name = "Pagos", catalog = "Grupo05_DDA_PAF", schema = "dbo")
@NamedQueries({
    @NamedQuery(name = "Pagos.findAll", query = "SELECT p FROM Pagos p"),
    @NamedQuery(name = "Pagos.findByIdPago", query = "SELECT p FROM Pagos p WHERE p.idPago = :idPago"),
    @NamedQuery(name = "Pagos.findByIdCliente", query = "SELECT p FROM Pagos p WHERE p.idCliente = :idCliente"),
    @NamedQuery(name = "Pagos.findByIdEmpleado", query = "SELECT p FROM Pagos p WHERE p.idEmpleado = :idEmpleado"),
    @NamedQuery(name = "Pagos.findByMonto", query = "SELECT p FROM Pagos p WHERE p.monto = :monto"),
    @NamedQuery(name = "Pagos.findByMetodoPago", query = "SELECT p FROM Pagos p WHERE p.metodoPago = :metodoPago"),
    @NamedQuery(name = "Pagos.findByFechaPago", query = "SELECT p FROM Pagos p WHERE p.fechaPago = :fechaPago")})
public class Pagos implements Serializable {

    private static final long serialVersionUID = 1L;
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // <--- ESTA ES LA SOLUCIÓN
    @Basic(optional = false)
    @Column(name = "id_pago", nullable = false)
    private Integer idPago;
    
    @Basic(optional = false)
    @Column(name = "id_cliente", nullable = false)
    private int idCliente;
    
    @Basic(optional = false)
    @Column(name = "id_empleado", nullable = false)
    private int idEmpleado;
    
    @Basic(optional = false)
    @Column(name = "monto", nullable = false, precision = 10, scale = 2)
    private BigDecimal monto;
    
    @Basic(optional = false)
    @Column(name = "metodo_pago", nullable = false, length = 50)
    private String metodoPago;
    
    @Column(name = "fecha_pago")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaPago;
    
    @JoinColumn(name = "id_pedido", referencedColumnName = "id_pedido", nullable = false)
    @ManyToOne(optional = false)
    private Pedidos idPedido;

    public Pagos() {
    }

    public Pagos(Integer idPago) {
        this.idPago = idPago;
    }

    public Pagos(Integer idPago, int idCliente, int idEmpleado, BigDecimal monto, String metodoPago) {
        this.idPago = idPago;
        this.idCliente = idCliente;
        this.idEmpleado = idEmpleado;
        this.monto = monto;
        this.metodoPago = metodoPago;
    }

    public Integer getIdPago() {
        return idPago;
    }

    public void setIdPago(Integer idPago) {
        this.idPago = idPago;
    }

    public int getIdCliente() {
        return idCliente;
    }

    public void setIdCliente(int idCliente) {
        this.idCliente = idCliente;
    }

    public int getIdEmpleado() {
        return idEmpleado;
    }

    public void setIdEmpleado(int idEmpleado) {
        this.idEmpleado = idEmpleado;
    }

    public BigDecimal getMonto() {
        return monto;
    }

    public void setMonto(BigDecimal monto) {
        this.monto = monto;
    }

    public String getMetodoPago() {
        return metodoPago;
    }

    public void setMetodoPago(String metodoPago) {
        this.metodoPago = metodoPago;
    }

    public Date getFechaPago() {
        return fechaPago;
    }

    public void setFechaPago(Date fechaPago) {
        this.fechaPago = fechaPago;
    }

    public Pedidos getIdPedido() {
        return idPedido;
    }

    public void setIdPedido(Pedidos idPedido) {
        this.idPedido = idPedido;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (idPago != null ? idPago.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        if (!(object instanceof Pagos)) {
            return false;
        }
        Pagos other = (Pagos) object;
        if ((this.idPago == null && other.idPago != null) || (this.idPago != null && !this.idPago.equals(other.idPago))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "entidades.Pagos[ idPago=" + idPago + " ]";
    }
    
}
