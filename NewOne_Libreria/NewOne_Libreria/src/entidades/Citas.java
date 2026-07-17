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
import java.util.Date;

@Entity
@Table(name = "Citas", catalog = "Grupo05_DDA_PAF", schema = "dbo")
@NamedQueries({
    @NamedQuery(name = "Citas.findAll", query = "SELECT c FROM Citas c"),
    @NamedQuery(name = "Citas.findByIdCita", query = "SELECT c FROM Citas c WHERE c.idCita = :idCita")})
public class Citas implements Serializable {

    private static final long serialVersionUID = 1L;
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Basic(optional = false)
    @Column(name = "id_cita", nullable = false)
    private Integer idCita;
    
    @Column(name = "fecha_hora_programada")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaHoraProgramada;
    
    @Column(name = "modalidad", length = 50)
    private String modalidad;
    
    @Column(name = "direccion_recojo", length = 255)
    private String direccionRecojo;
    
    @Column(name = "estado", length = 50)
    private String estado;
    
    @Column(name = "fecha_solicitud")
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaSolicitud;
    
    @JoinColumn(name = "id_cliente", referencedColumnName = "id_cliente", nullable = false)
    @ManyToOne(optional = false)
    private Clientes idCliente;

    public Citas() {
    }

    public Citas(Integer idCita) {
        this.idCita = idCita;
    }

    // Getters y Setters
    public Integer getIdCita() { return idCita; }
    public void setIdCita(Integer idCita) { this.idCita = idCita; }

    public Date getFechaHoraProgramada() { return fechaHoraProgramada; }
    public void setFechaHoraProgramada(Date fechaHoraProgramada) { this.fechaHoraProgramada = fechaHoraProgramada; }

    public String getModalidad() { return modalidad; }
    public void setModalidad(String modalidad) { this.modalidad = modalidad; }

    public String getDireccionRecojo() { return direccionRecojo; }
    public void setDireccionRecojo(String direccionRecojo) { this.direccionRecojo = direccionRecojo; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public Date getFechaSolicitud() { return fechaSolicitud; }
    public void setFechaSolicitud(Date fechaSolicitud) { this.fechaSolicitud = fechaSolicitud; }

    public Clientes getIdCliente() { return idCliente; }
    public void setIdCliente(Clientes idCliente) { this.idCliente = idCliente; }

    @Override
    public int hashCode() {
        int hash = 0;
        hash += (idCita != null ? idCita.hashCode() : 0);
        return hash;
    }

    @Override
    public boolean equals(Object object) {
        if (!(object instanceof Citas)) return false;
        Citas other = (Citas) object;
        if ((this.idCita == null && other.idCita != null) || (this.idCita != null && !this.idCita.equals(other.idCita))) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "entidades.Citas[ idCita=" + idCita + " ]";
    }
}
