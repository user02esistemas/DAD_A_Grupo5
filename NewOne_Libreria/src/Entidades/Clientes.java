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
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.OneToMany;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import java.io.Serializable;
import java.util.Date;
import java.util.List;

@Entity
@Table(name = "Clientes", catalog = "Grupo05_DDA_PAF", schema = "dbo")
@NamedQueries({
    @NamedQuery(name = "Clientes.findAll", query = "SELECT c FROM Clientes c"),
    @NamedQuery(name = "Clientes.findByIdCliente", query = "SELECT c FROM Clientes c WHERE c.idCliente = :idCliente"),
    @NamedQuery(name = "Clientes.findByEmail", query = "SELECT c FROM Clientes c WHERE c.email = :email")})
public class Clientes implements Serializable {

    private static final long serialVersionUID = 1L;
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "id_cliente", nullable = false)
    private Integer idCliente;

    // Mapeo exacto a columnas de BD (snake_case y sin tildes)
    @Column(name = "nombre_completo", length = 100)
    private String nombreCompleto;
    
    @Column(name = "email", length = 100)
    private String email;
    
    @Column(name = "password", length = 100)
    private String password;
    
    @Column(name = "telefono", length = 20)
    private String telefono;
    
    @Column(name = "direccion", length = 255)
    private String direccion;
    
    @Column(name = "fecha_nacimiento", length = 50)
    private String fechaNacimiento;
    
    @Column(name = "referido_por", length = 20)
    private String referidoPor;
    
    @Column(name = "fecha_registro")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaRegistro;
    
    @Column(name = "codigo_referido", length = 20)
    private String codigoReferido;
    
    @Column(name = "apto_promociones")
    private Boolean aptoPromociones;
    
    // Relaciones con otras tablas
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "idCliente")
    private List<Pedidos> pedidosList;
    
    @OneToMany(cascade = CascadeType.ALL, mappedBy = "idCliente")
    private List<Citas> citasList;

    public Clientes() {
    }

    public Clientes(Integer idCliente) {
        this.idCliente = idCliente;
    }

    public Integer getIdCliente() { return idCliente; }
    public void setIdCliente(Integer idCliente) { this.idCliente = idCliente; }

    public String getNombreCompleto() { return nombreCompleto; }
    public void setNombreCompleto(String nombreCompleto) { this.nombreCompleto = nombreCompleto; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }

    public String getDireccion() { return direccion; }
    public void setDireccion(String direccion) { this.direccion = direccion; }

    public String getFechaNacimiento() { return fechaNacimiento; }
    public void setFechaNacimiento(String fechaNacimiento) { this.fechaNacimiento = fechaNacimiento; }

    public String getReferidoPor() { return referidoPor; }
    public void setReferidoPor(String referidoPor) { this.referidoPor = referidoPor; }

    public Date getFechaRegistro() { return fechaRegistro; }
    public void setFechaRegistro(Date fechaRegistro) { this.fechaRegistro = fechaRegistro; }

    public String getCodigoReferido() { return codigoReferido; }
    public void setCodigoReferido(String codigoReferido) { this.codigoReferido = codigoReferido; }

    public Boolean getAptoPromociones() { return aptoPromociones; }
    public void setAptoPromociones(Boolean aptoPromociones) { this.aptoPromociones = aptoPromociones; }
    
    // Helper para JSPs
    public Boolean isAptoPromociones() { return aptoPromociones != null && aptoPromociones; }

    public List<Pedidos> getPedidosList() { return pedidosList; }
    public void setPedidosList(List<Pedidos> pedidosList) { this.pedidosList = pedidosList; }

    public List<Citas> getCitasList() { return citasList; }
    public void setCitasList(List<Citas> citasList) { this.citasList = citasList; }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (idCliente != null ? idCliente.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        if (!(object instanceof Clientes)) return false;
        Clientes other = (Clientes) object;
        if ((this.idCliente == null && other.idCliente != null) || (this.idCliente != null && !this.idCliente.equals(other.idCliente))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "entidades.Clientes[ idCliente=" + idCliente + " ]";
    }
}
