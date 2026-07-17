/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package entidades;

import javax.persistence.Basic;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.List;

/**
 *
 * @author diego
 */
@Entity
@Table(name = "Servicios", catalog = "Grupo05_DDA_PAF", schema = "dbo")
@NamedQueries({
    @NamedQuery(name = "Servicios.findAll", query = "SELECT s FROM Servicios s"),
    @NamedQuery(name = "Servicios.findByIdServicio", query = "SELECT s FROM Servicios s WHERE s.idServicio = :idServicio"),
    @NamedQuery(name = "Servicios.findByNombre", query = "SELECT s FROM Servicios s WHERE s.nombre = :nombre"),
    @NamedQuery(name = "Servicios.findByDescripcion", query = "SELECT s FROM Servicios s WHERE s.descripcion = :descripcion"),
    @NamedQuery(name = "Servicios.findByPrecio", query = "SELECT s FROM Servicios s WHERE s.precio = :precio"),
    @NamedQuery(name = "Servicios.findByTipo", query = "SELECT s FROM Servicios s WHERE s.tipo = :tipo"),
    @NamedQuery(name = "Servicios.findByImagenUrl", query = "SELECT s FROM Servicios s WHERE s.imagenUrl = :imagenUrl"),
    @NamedQuery(name = "Servicios.findByStock", query = "SELECT s FROM Servicios s WHERE s.stock = :stock"),
    @NamedQuery(name = "Servicios.findByDisponible", query = "SELECT s FROM Servicios s WHERE s.disponible = :disponible")})
public class Servicios implements Serializable {

    private static final long serialVersionUID = 1L;
    @Id
    @Basic(optional = false)
    @Column(name = "id_servicio", nullable = false)
    private Integer idServicio;
    @Basic(optional = false)
    @Column(name = "nombre", nullable = false, length = 100)
    private String nombre;
    @Column(name = "descripcion", length = 255)
    private String descripcion;
    @Basic(optional = false)
    @Column(name = "precio", nullable = false, precision = 10, scale = 2)
    private BigDecimal precio;
    @Column(name = "tipo", length = 50)
    private String tipo;
    @Column(name = "imagen_url", length = 2147483647)
    private String imagenUrl;
    @Column(name = "stock")
    private Integer stock;
    @Column(name = "disponible")
    private Boolean disponible;
    @OneToMany(mappedBy = "idServicio")
    private List<DetallePedido> detallePedidoList;

    public Servicios() {
    }

    public Servicios(Integer idServicio) {
        this.idServicio = idServicio;
    }

    public Servicios(Integer idServicio, String nombre, BigDecimal precio) {
        this.idServicio = idServicio;
        this.nombre = nombre;
        this.precio = precio;
    }

    public Integer getIdServicio() {
        return idServicio;
    }

    public void setIdServicio(Integer idServicio) {
        this.idServicio = idServicio;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public BigDecimal getPrecio() {
        return precio;
    }

    public void setPrecio(BigDecimal precio) {
        this.precio = precio;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public String getImagenUrl() {
        return imagenUrl;
    }

    public void setImagenUrl(String imagenUrl) {
        this.imagenUrl = imagenUrl;
    }

    public Integer getStock() {
        return stock;
    }

    public void setStock(Integer stock) {
        this.stock = stock;
    }

    public Boolean getDisponible() {
        return disponible;
    }

    public void setDisponible(Boolean disponible) {
        this.disponible = disponible;
    }

    public List<DetallePedido> getDetallePedidoList() {
        return detallePedidoList;
    }

    public void setDetallePedidoList(List<DetallePedido> detallePedidoList) {
        this.detallePedidoList = detallePedidoList;
    }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (idServicio != null ? idServicio.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        if (!(object instanceof Servicios)) {
            return false;
        }
        Servicios other = (Servicios) object;
        if ((this.idServicio == null && other.idServicio != null) || (this.idServicio != null && !this.idServicio.equals(other.idServicio))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "entidades.Servicios[ idServicio=" + idServicio + " ]";
    }
    
}
