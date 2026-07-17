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
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import javax.persistence.UniqueConstraint;
import java.io.Serializable;
import java.util.Date;
import java.util.List;

@Entity
@Table(name = "Empleados", catalog = "Grupo05_DDA_PAF", schema = "dbo", uniqueConstraints = {
    @UniqueConstraint(columnNames = {"codigo_empleado"})})
@NamedQueries({
    @NamedQuery(name = "Empleados.findAll", query = "SELECT e FROM Empleados e"),
    @NamedQuery(name = "Empleados.findByIdUsuario", query = "SELECT e FROM Empleados e WHERE e.idUsuario = :idUsuario")})
public class Empleados implements Serializable {

    private static final long serialVersionUID = 1L;
    

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) 
    @Basic(optional = false)
    @Column(name = "id_usuario", nullable = false)
    private Integer idUsuario;
    // -----------------------

    @Basic(optional = false)
    @Column(name = "codigo_empleado", nullable = false, length = 50)
    private String codigoEmpleado;
    
    @Basic(optional = false)
    @Column(name = "password", nullable = false, length = 100)
    private String password;
    
    @Basic(optional = false)
    @Column(name = "nombre_completo", nullable = false, length = 100)
    private String nombreCompleto;
    
    @Column(name = "rol", length = 20)
    private String rol;
    
    @Column(name = "estado")
    private Boolean estado;
    
    @Column(name = "fecha_creacion")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaCreacion;
    
    @OneToMany(mappedBy = "idEmpleado")
    private List<Pedidos> pedidosList;

    public Empleados() {
    }

    public Empleados(Integer idUsuario) {
        this.idUsuario = idUsuario;
    }

    public Integer getIdUsuario() { return idUsuario; }
    public void setIdUsuario(Integer idUsuario) { this.idUsuario = idUsuario; }

    public String getCodigoEmpleado() { return codigoEmpleado; }
    public void setCodigoEmpleado(String codigoEmpleado) { this.codigoEmpleado = codigoEmpleado; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getNombreCompleto() { return nombreCompleto; }
    public void setNombreCompleto(String nombreCompleto) { this.nombreCompleto = nombreCompleto; }

    public String getRol() { return rol; }
    public void setRol(String rol) { this.rol = rol; }

    public Boolean getEstado() { return estado; }
    public void setEstado(Boolean estado) { this.estado = estado; }

    public Date getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(Date fechaCreacion) { this.fechaCreacion = fechaCreacion; }

    public List<Pedidos> getPedidosList() { return pedidosList; }
    public void setPedidosList(List<Pedidos> pedidosList) { this.pedidosList = pedidosList; }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (idUsuario != null ? idUsuario.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        if (!(object instanceof Empleados)) return false;
        Empleados other = (Empleados) object;
        if ((this.idUsuario == null && other.idUsuario != null) || (this.idUsuario != null && !this.idUsuario.equals(other.idUsuario))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "entidades.Empleados[ idUsuario=" + idUsuario + " ]";
    }
}
