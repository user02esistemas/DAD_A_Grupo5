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
@Table(name = "Detalle_Pedido", catalog = "Grupo05_DDA_PAF", schema = "dbo")
@NamedQueries({
    @NamedQuery(name = "DetallePedido.findAll", query = "SELECT d FROM DetallePedido d"),
    @NamedQuery(name = "DetallePedido.findByIdDetalle", query = "SELECT d FROM DetallePedido d WHERE d.idDetalle = :idDetalle"),
    @NamedQuery(name = "DetallePedido.findByCantidad", query = "SELECT d FROM DetallePedido d WHERE d.cantidad = :cantidad"),
    @NamedQuery(name = "DetallePedido.findBySubtotal", query = "SELECT d FROM DetallePedido d WHERE d.subtotal = :subtotal"),
    @NamedQuery(name = "DetallePedido.findByFechaProgramadaRecojo", query = "SELECT d FROM DetallePedido d WHERE d.fechaProgramadaRecojo = :fechaProgramadaRecojo"),
    @NamedQuery(name = "DetallePedido.findByProductoEntregado", query = "SELECT d FROM DetallePedido d WHERE d.productoEntregado = :productoEntregado")})
public class DetallePedido implements Serializable {

    private static final long serialVersionUID = 1L;
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "id_detalle", nullable = false)
    private Integer idDetalle;
    // -----------------------

    @Column(name = "cantidad")
    private Integer cantidad;
    
    @Column(name = "subtotal", precision = 10, scale = 2)
    private BigDecimal subtotal;
    
    @Column(name = "fecha_programada_recojo")
    @Temporal(TemporalType.DATE)
    private Date fechaProgramadaRecojo;
    
    @Column(name = "producto_entregado")
    private Boolean productoEntregado;
    
    @JoinColumn(name = "id_pedido", referencedColumnName = "id_pedido", nullable = false)
    @ManyToOne(optional = false)
    private Pedidos idPedido;
    
    @JoinColumn(name = "id_producto", referencedColumnName = "id_producto")
    @ManyToOne
    private Productos idProducto;
    
    @JoinColumn(name = "id_servicio", referencedColumnName = "id_servicio")
    @ManyToOne
    private Servicios idServicio;

    public DetallePedido() {
    }

    public DetallePedido(Integer idDetalle) {
        this.idDetalle = idDetalle;
    }

    public Integer getIdDetalle() {
        return idDetalle;
    }

    public void setIdDetalle(Integer idDetalle) {
        this.idDetalle = idDetalle;
    }

    public Integer getCantidad() {
        return cantidad;
    }

    public void setCantidad(Integer cantidad) {
        this.cantidad = cantidad;
    }

    public BigDecimal getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(BigDecimal subtotal) {
        this.subtotal = subtotal;
    }

    public Date getFechaProgramadaRecojo() {
        return fechaProgramadaRecojo;
    }

    public void setFechaProgramadaRecojo(Date fechaProgramadaRecojo) {
        this.fechaProgramadaRecojo = fechaProgramadaRecojo;
    }

    public Boolean getProductoEntregado() {
        return productoEntregado;
    }

    public void setProductoEntregado(Boolean productoEntregado) {
        this.productoEntregado = productoEntregado;
    }

    public Pedidos getIdPedido() {
        return idPedido;
    }

    public void setIdPedido(Pedidos idPedido) {
        this.idPedido = idPedido;
    }

    public Productos getIdProducto() {
        return idProducto;
    }

    public void setIdProducto(Productos idProducto) {
        this.idProducto = idProducto;
    }

    public Servicios getIdServicio() {
        return idServicio;
    }

    public void setIdServicio(Servicios idServicio) {
        this.idServicio = idServicio;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (idDetalle != null ? idDetalle.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        if (!(object instanceof DetallePedido)) {
            return false;
        }
        DetallePedido other = (DetallePedido) object;
        if ((this.idDetalle == null && other.idDetalle != null) || (this.idDetalle != null && !this.idDetalle.equals(other.idDetalle))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "entidades.DetallePedido[ idDetalle=" + idDetalle + " ]";
    }
    
}
